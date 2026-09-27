import 'package:dio/dio.dart';

import 'chain_models.dart';
import 'evm/evm_rpc.dart';

/// Authenticated chain services. Credentials are sent only to the wallet API.
/// No write retry or public-node fallback, including ambiguous broadcasts.
class ChainBackendClient {
  ChainBackendClient({
    required this.config,
    required this.baseUrl,
    required this.accountReader,
    required this.headersReader,
    required this.proofSigner,
    required this.guard,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 15),
             ),
           ) {
    if (Uri.tryParse(baseUrl)?.scheme != 'https') {
      throw ArgumentError('Wallet backend must use HTTPS.');
    }
  }
  final ChainConfig config;
  final String baseUrl;
  final Future<ChainAccount> Function() accountReader;
  final Future<Map<String, String>> Function() headersReader;
  final Future<String> Function(String message) proofSigner;
  final void Function() guard;
  final Dio _dio;
  Future<void>? _binding;
  String? _boundAddress;
  int _sequence = 0;

  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    guard();
    final headers = await headersReader();
    guard();
    try {
      final response = await _dio.request<dynamic>(
        '$baseUrl$path',
        data: body,
        queryParameters: query,
        options: Options(
          method: body == null ? 'GET' : 'POST',
          followRedirects: false,
          headers: {...headers, 'X-Chain-Id': '${config.chainId}'},
        ),
      );
      guard();
      if (response.data is! Map)
        throw const EvmRpcException('Invalid wallet service response.');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (error) {
      guard();
      final status = error.response?.statusCode;
      if (status == 409 &&
          error.response?.data is Map &&
          error.response?.data['error'] == 'network_mismatch')
        throw const EvmNetworkMismatch();
      if (status == 401)
        throw const EvmRpcException('Wallet session expired. Unlock again.');
      if (status == 403)
        throw const EvmRpcException(
          'Wallet service denied this action. Check the account and permissions.',
        );
      if (status == 429)
        throw const EvmRpcException(
          'Wallet service is busy. Try again shortly.',
        );
      throw const EvmRpcException(
        'Wallet service unavailable. A submitted transaction may still complete; check activity before sending again.',
      );
    }
  }

  Future<void> ensureBound() async {
    guard();
    if (_boundAddress != null) return;
    if (_binding != null) return _binding!;
    final future = _bind();
    _binding = future;
    try {
      await future;
    } finally {
      if (identical(_binding, future)) _binding = null;
    }
  }

  Future<void> _bind() async {
    final account = await accountReader();
    final existing = await request('/v1/chains/arc/account');
    if (existing['account'] is Map) {
      if ((existing['account'] as Map)['address'] !=
          account.address.toLowerCase()) {
        throw const EvmRpcException(
          'The backend account does not match this wallet.',
        );
      }
    } else {
      final proof = await request(
        '/v1/chains/arc/account/challenge',
        body: {'address': account.address},
      );
      final message = validateAccountProof(proof, account);
      guard();
      final signature = await proofSigner(message);
      guard();
      await request(
        '/v1/chains/arc/account/verify',
        body: {
          'address': account.address,
          'nonce': proof['nonce'],
          'signature': signature,
        },
      );
    }
    guard();
    _boundAddress = account.address.toLowerCase();
  }

  Future<dynamic> rpc(String method, List<dynamic> params) async {
    if (method == 'eth_sendRawTransaction') await ensureBound();
    final id = ++_sequence;
    final response = await request(
      '/v1/arc-rpc',
      body: {'jsonrpc': '2.0', 'id': id, 'method': method, 'params': params},
    );
    if (response['jsonrpc'] != '2.0' ||
        response['id'] != id ||
        !response.containsKey('result')) {
      throw const EvmRpcException('Invalid chain service response.');
    }
    return response['result'];
  }

  Future<List<ChainAsset>> tokens() async {
    await ensureBound();
    final response = await request('/v1/chains/arc/tokens');
    return (response['tokens'] as List).map((v) => _asset(v as Map)).toList();
  }

  Future<ChainAsset> importToken(String contract) async {
    await ensureBound();
    final response = await request(
      '/v1/chains/arc/tokens',
      body: {'contractAddress': contract},
    );
    return _asset(response['token'] as Map);
  }

  Future<List<ChainAsset>> portfolio() async {
    await ensureBound();
    final response = await request('/v1/chains/arc/portfolio');
    if ((response['chain'] as Map)['chainId'] != config.chainId ||
        response['address'] != _boundAddress)
      throw const EvmNetworkMismatch();
    return (response['assets'] as List).map((v) => _asset(v as Map)).toList();
  }

  ChainAsset _asset(Map value) {
    final asset = ChainAsset.fromJson(Map<String, dynamic>.from(value));
    if (asset.chainId != config.id) throw const EvmNetworkMismatch();
    return asset;
  }

  Future<ChainHistoryPage> history({String? cursor}) async {
    await ensureBound();
    final response = await request(
      '/v1/chains/arc/activity',
      query: {'limit': 50, if (cursor != null) 'cursor': cursor},
    );
    final items = <ChainActivity>[];
    for (final item in [
      ...response['items'] as List,
      ...response['submissions'] as List,
    ]) {
      final row = Map<String, dynamic>.from(item as Map);
      if (row['chainId'] != config.id) throw const EvmNetworkMismatch();
      items.add(
        ChainActivity(
          chainId: config.id,
          hash: row['hash'] as String,
          from: row['from'] as String,
          to: row['to'] as String,
          asset: _asset(row['asset'] as Map),
          amount: BigInt.parse(row['amount'] as String),
          status: ChainTransactionStatus.values.byName(row['status'] as String),
          timestamp: DateTime.tryParse(row['timestamp'] as String? ?? ''),
          fee: row['fee'] == null ? null : BigInt.parse(row['fee'] as String),
          logIndex: row['logIndex'] as int?,
          type: row['type'] as String? ?? 'transfer',
        ),
      );
    }
    final coverage = Map<String, dynamic>.from(response['coverage'] as Map);
    return ChainHistoryPage(
      items: mergeChainHistory(items),
      nextCursor: response['nextCursor'] as String?,
      backfillComplete: coverage['backfillComplete'] == true,
    );
  }
}

/// Reconstruct this narrow authentication message locally; never blindly sign
/// arbitrary backend text or allow a challenge to authorize spending.
String validateAccountProof(
  Map<String, dynamic> proof,
  ChainAccount account, {
  DateTime? now,
}) {
  now ??= DateTime.now().toUtc();
  final nonce = proof['nonce'], expires = proof['expiresAt'];
  final expiration = expires is String ? DateTime.tryParse(expires) : null;
  if (nonce is! String ||
      !RegExp(r'^[0-9a-f]{48}$').hasMatch(nonce) ||
      expiration == null ||
      !expiration.isAfter(now) ||
      expiration.difference(now) > const Duration(minutes: 6) ||
      proof['ownerAddress'] != account.rootWalletId ||
      proof['chainId'] != account.chainId ||
      proof['address'] != account.address.toLowerCase()) {
    throw const EvmRpcException('Invalid account verification request.');
  }
  final expected = [
    'Benny Wallet account binding',
    'Owner: ${account.rootWalletId}',
    'Network: ${account.chainId}',
    'Address: ${account.address.toLowerCase()}',
    'Nonce: $nonce',
    'Expires: $expires',
    'This proof links public accounts. It does not authorize a transfer.',
  ].join('\n');
  if (proof['message'] != expected)
    throw const EvmRpcException('Account verification message changed.');
  return expected;
}

class BackendEvmRpc implements EvmRpc {
  BackendEvmRpc(this.client);
  final ChainBackendClient client;
  @override
  Future<void> verifyNetwork() async {
    final id = await client.rpc('eth_chainId', []);
    if (id is! String ||
        BigInt.tryParse(id) != BigInt.from(client.config.chainId!))
      throw const EvmNetworkMismatch();
  }

  @override
  Future<dynamic> call(String method, List<dynamic> params) async {
    await verifyNetwork();
    return client.rpc(method, params);
  }
}

class ChainHistoryPage {
  const ChainHistoryPage({
    required this.items,
    this.nextCursor,
    this.backfillComplete = false,
  });
  final List<ChainActivity> items;
  final String? nextCursor;
  final bool backfillComplete;
}

List<ChainActivity> mergeChainHistory(List<ChainActivity> items) {
  final eventHashes = items
      .where((i) => i.logIndex != null)
      .map((i) => '${i.chainId}:${i.hash}')
      .toSet();
  final unique = <String, ChainActivity>{};
  for (final item in items) {
    if (item.logIndex == null &&
        eventHashes.contains('${item.chainId}:${item.hash}'))
      continue;
    unique.putIfAbsent(item.id, () => item);
  }
  return unique.values.toList()..sort(
    (a, b) => (b.timestamp ?? DateTime(1970)).compareTo(
      a.timestamp ?? DateTime(1970),
    ),
  );
}

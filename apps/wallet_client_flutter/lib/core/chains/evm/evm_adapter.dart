import 'dart:convert';
import 'dart:typed_data';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../chain_adapter.dart';
import '../chain_models.dart';
import 'evm_key_service.dart';
import 'evm_rpc.dart';

const _transferTopic =
    '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';
final _erc20 = ContractAbi.fromJson(
  jsonEncode([
    for (final name in ['name', 'symbol'])
      {
        'type': 'function',
        'name': name,
        'stateMutability': 'view',
        'inputs': [],
        'outputs': [
          {'name': '', 'type': 'string'},
        ],
      },
    {
      'type': 'function',
      'name': 'decimals',
      'stateMutability': 'view',
      'inputs': [],
      'outputs': [
        {'name': '', 'type': 'uint8'},
      ],
    },
    {
      'type': 'function',
      'name': 'balanceOf',
      'stateMutability': 'view',
      'inputs': [
        {'name': 'owner', 'type': 'address'},
      ],
      'outputs': [
        {'name': '', 'type': 'uint256'},
      ],
    },
    {
      'type': 'function',
      'name': 'transfer',
      'stateMutability': 'nonpayable',
      'inputs': [
        {'name': 'to', 'type': 'address'},
        {'name': 'value', 'type': 'uint256'},
      ],
      'outputs': [
        {'name': '', 'type': 'bool'},
      ],
    },
  ]),
  'ERC20',
);

BigInt _quantity(dynamic value) {
  if (value is! String || !RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(value)) {
    throw const EvmRpcException(
      'Invalid numeric value returned by the network.',
    );
  }
  return BigInt.parse(value.substring(2), radix: 16);
}

String _hex(BigInt value) => '0x${value.toRadixString(16)}';
bool _sameAddress(String a, String b) => a.toLowerCase() == b.toLowerCase();

class _EvmPayload {
  const _EvmPayload(this.transaction, this.chainId);
  final Transaction transaction;
  final int chainId;
}

/// Generic EVM adapter. Native/ERC-20 aliases, precision, fee floor and finality
/// are network metadata; no Arc protocol conditionals leak into Flutter widgets.
class EvmAdapter extends ChainAdapter {
  EvmAdapter({
    required this.config,
    required Future<ChainAccount> Function() accountReader,
    required Future<String> Function() mnemonicReader,
    EvmRpc? rpc,
    List<String>? rpcUrls,
  }) : _accountReader = accountReader,
       _mnemonicReader = mnemonicReader,
       rpc =
           rpc ??
           DioEvmRpc(
             chainId: config.chainId!,
             urls: rpcUrls ?? [config.rpcUrl],
           ) {
    if (config.family != ChainFamily.evm ||
        config.chainId == null ||
        config.chainId! <= 0) {
      throw ArgumentError('A valid EVM chain configuration is required.');
    }
  }

  @override
  final ChainConfig config;
  final EvmRpc rpc;
  final Future<ChainAccount> Function() _accountReader;
  final Future<String> Function() _mnemonicReader;
  final Map<String, ChainTransferRequest> _tracked = {};
  final Map<String, PreparedChainTransaction> _signedEnvelopes = {};
  final Map<String, String> _broadcastNonces = {};
  final Set<String> _broadcasting = {};
  static const historyBlockWindow = 1000;
  static const historyWindowLabel =
      'Recent activity: latest 1,000 blocks plus transactions sent on this device.';

  ChainAsset get nativeAsset => ChainAsset(
    chainId: config.id,
    symbol: config.feeSymbol,
    name: config.feeSymbol,
    decimals: config.nativeTokenDecimals ?? config.feeDecimals,
    contractAddress: config.nativeTokenContract,
    rawBalance: BigInt.zero,
    isFeeAsset: true,
  );

  @override
  Future<ChainAccount> getAccount() async {
    final account = await _accountReader();
    _checkAccount(account);
    return account;
  }

  void _checkAccount(ChainAccount account) {
    if (account.chainId != config.id || !validateAddress(account.address)) {
      throw StateError('The selected account does not belong to this network.');
    }
  }

  @override
  bool validateAddress(String address) {
    if (!RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(address)) return false;
    try {
      EthereumAddress.fromHex(address);
      return !RegExp(r'^0x0{40}$').hasMatch(address);
    } catch (_) {
      return false;
    }
  }

  bool _isNativeAlias(ChainAsset asset) =>
      asset.contractAddress == null ||
      (config.nativeTokenContract != null &&
          _sameAddress(asset.contractAddress!, config.nativeTokenContract!));

  void _checkAsset(ChainAsset asset) {
    if (asset.chainId != config.id ||
        asset.decimals < 0 ||
        asset.decimals > 36 ||
        (asset.contractAddress != null &&
            !validateAddress(asset.contractAddress!))) {
      throw ArgumentError('Invalid asset or network.');
    }
    if (_isNativeAlias(asset)) {
      final expected = asset.contractAddress == null
          ? config.feeDecimals
          : config.nativeTokenDecimals;
      if (asset.decimals != expected)
        throw ArgumentError('Invalid native asset precision.');
    }
  }

  Future<BigInt> getNativeBalance(ChainAccount account) async {
    _checkAccount(account);
    return _quantity(
      await rpc.call('eth_getBalance', [account.address, 'latest']),
    );
  }

  Future<List<dynamic>> _callToken(
    String address,
    String name,
    List<dynamic> args,
  ) async {
    final function = _erc20.functions.singleWhere((f) => f.name == name);
    final encoded = bytesToHex(function.encodeCall(args), include0x: true);
    final result = await rpc.call('eth_call', [
      {'to': address, 'data': encoded},
      'latest',
    ]);
    if (result is! String || result.length > 16386) {
      throw const EvmRpcException('Invalid token metadata response.');
    }
    try {
      return function.decodeReturnValues(result);
    } catch (_) {
      throw const EvmRpcException(
        'This contract does not provide supported ERC-20 metadata.',
      );
    }
  }

  @override
  Future<BigInt> getBalance(ChainAccount account, ChainAsset asset) async {
    _checkAccount(account);
    _checkAsset(asset);
    if (_isNativeAlias(asset)) {
      final raw = await getNativeBalance(account);
      return raw ~/ BigInt.from(10).pow(config.feeDecimals - asset.decimals);
    }
    return (await _callToken(asset.contractAddress!, 'balanceOf', [
          EthereumAddress.fromHex(account.address),
        ])).single
        as BigInt;
  }

  @override
  Future<List<ChainAsset>> getAssets(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
  }) async {
    final assets = <String, ChainAsset>{nativeAsset.id: nativeAsset};
    for (final token in tokens) {
      _checkAsset(token);
      if (!_isNativeAlias(token)) assets[token.id] = token;
    }
    return Future.wait(
      assets.values.map(
        (asset) async => asset.withBalance(await getBalance(account, asset)),
      ),
    );
  }

  Future<ChainAsset> importToken(String address) async {
    if (!validateAddress(address))
      throw const FormatException('Enter a valid contract address.');
    if (config.nativeTokenContract != null &&
        _sameAddress(address, config.nativeTokenContract!)) {
      return nativeAsset;
    }
    final code = await rpc.call('eth_getCode', [address, 'latest']);
    if (code is! String || code == '0x' || code == '0x0') {
      throw const FormatException(
        'No token contract exists at this address on the selected network.',
      );
    }
    final results = await Future.wait([
      _callToken(address, 'name', []),
      _callToken(address, 'symbol', []),
      _callToken(address, 'decimals', []),
    ]);
    final name = results[0].single as String;
    final symbol = results[1].single as String;
    final decimals = (results[2].single as BigInt).toInt();
    if (name.trim().isEmpty ||
        name.length > 128 ||
        symbol.trim().isEmpty ||
        symbol.length > 32 ||
        RegExp(
          r'[\x00-\x1f\x7f\u202a-\u202e\u2066-\u2069]',
        ).hasMatch('$name$symbol') ||
        decimals > 36) {
      throw const FormatException('Token metadata is invalid or unsupported.');
    }
    return ChainAsset(
      chainId: config.id,
      contractAddress: EthereumAddress.fromHex(address).hexEip55,
      name: name.trim(),
      symbol: symbol.trim(),
      decimals: decimals,
      rawBalance: BigInt.zero,
    );
  }

  void _checkRequest(ChainTransferRequest request) {
    _checkAccount(request.account);
    _checkAsset(request.asset);
    if (!request.account.canSign)
      throw StateError('This account cannot sign transactions.');
    if (!validateAddress(request.to))
      throw const FormatException('Enter a valid recipient address.');
    if (request.amount <= BigInt.zero ||
        request.amount >= (BigInt.one << 256)) {
      throw const FormatException(
        'Enter a positive amount within the supported range.',
      );
    }
  }

  Transaction _transfer(ChainTransferRequest request) {
    _checkRequest(request);
    final contract = request.asset.contractAddress;
    return Transaction(
      from: EthereumAddress.fromHex(request.account.address),
      to: EthereumAddress.fromHex(contract ?? request.to),
      value: EtherAmount.inWei(contract == null ? request.amount : BigInt.zero),
      data: contract == null
          ? Uint8List(0)
          : _erc20.functions
                .singleWhere((f) => f.name == 'transfer')
                .encodeCall([
                  EthereumAddress.fromHex(request.to),
                  request.amount,
                ]),
    );
  }

  Map<String, dynamic> _rpcTransaction(Transaction transaction) => {
    'from': transaction.from!.hex,
    'to': transaction.to!.hex,
    'value': _hex(transaction.value!.getInWei),
    'data': bytesToHex(transaction.data!, include0x: true),
    if (transaction.maxFeePerGas != null)
      'maxFeePerGas': _hex(transaction.maxFeePerGas!.getInWei),
    if (transaction.maxPriorityFeePerGas != null)
      'maxPriorityFeePerGas': _hex(transaction.maxPriorityFeePerGas!.getInWei),
  };

  @override
  Future<ChainFeeEstimate> estimateFee(ChainTransferRequest request) async {
    final transfer = _transfer(request);
    await rpc.verifyNetwork();
    final floor = BigInt.from(config.minimumGasPrice);
    var suggested = _quantity(await rpc.call('eth_gasPrice', []));
    var base = suggested;
    var tip = BigInt.zero;
    try {
      final history = await rpc.call('eth_feeHistory', [
        '0x5',
        'latest',
        [50],
      ]);
      if (history is Map &&
          history['baseFeePerGas'] is List &&
          (history['baseFeePerGas'] as List).isNotEmpty) {
        base = _quantity((history['baseFeePerGas'] as List).last);
        final reward = history['reward'];
        if (reward is List &&
            reward.isNotEmpty &&
            reward.last is List &&
            (reward.last as List).isNotEmpty) {
          tip = _quantity((reward.last as List).first);
        }
      }
    } on EvmNetworkMismatch {
      rethrow;
    } on EvmRpcException {
      // Some EVM providers do not expose feeHistory. gasPrice remains usable.
    }
    if (suggested < floor) suggested = floor;
    if (base < floor) base = floor;
    var maxFee = base * BigInt.two + tip;
    if (maxFee < suggested) maxFee = suggested;
    if (maxFee < floor) maxFee = floor;
    if (tip > maxFee) tip = maxFee;
    final rawGas = _quantity(
      await rpc.call('eth_estimateGas', [
        _rpcTransaction(
          transfer.copyWith(
            maxFeePerGas: EtherAmount.inWei(maxFee),
            maxPriorityFeePerGas: EtherAmount.inWei(tip),
          ),
        ),
      ]),
    );
    if (rawGas <= BigInt.zero || rawGas > BigInt.from(30000000)) {
      throw const EvmRpcException(
        'Network returned an unsupported gas estimate.',
      );
    }
    final gas =
        (rawGas * BigInt.from(120) + BigInt.from(99)) ~/ BigInt.from(100);
    final estimate = ChainFeeEstimate(
      chainId: config.id,
      symbol: config.feeSymbol,
      decimals: config.feeDecimals,
      gasLimit: gas,
      maxFeePerGas: maxFee,
      maxPriorityFeePerGas: tip,
      maxFee: gas * maxFee,
      estimatedFee: rawGas * (base + tip),
    );
    await _checkFunds(request, estimate);
    return estimate;
  }

  Future<void> _checkFunds(
    ChainTransferRequest request,
    ChainFeeEstimate fee,
  ) async {
    final native = await getNativeBalance(request.account);
    var needed = fee.maxFee;
    if (_isNativeAlias(request.asset)) {
      needed +=
          request.amount *
          BigInt.from(10).pow(config.feeDecimals - request.asset.decimals);
    } else if (await getBalance(request.account, request.asset) <
        request.amount) {
      throw StateError('Insufficient ${request.asset.symbol} balance.');
    }
    if (native < needed)
      throw StateError(
        'Insufficient ${config.feeSymbol} for the amount and network fee.',
      );
  }

  @override
  Future<PreparedChainTransaction> buildTransaction(
    ChainTransferRequest request, {
    ChainFeeEstimate? fee,
  }) async {
    final transfer = _transfer(request);
    await rpc.verifyNetwork();
    final quote = fee ?? await estimateFee(request);
    _validateFee(quote);
    await _checkFunds(request, quote);
    final nonce = _quantity(
      await rpc.call('eth_getTransactionCount', [
        request.account.address,
        'pending',
      ]),
    );
    if (nonce > BigInt.from(9007199254740991))
      throw const EvmRpcException('Unsupported account nonce.');
    return PreparedChainTransaction(
      request: request,
      fee: quote,
      payload: _EvmPayload(
        transfer.copyWith(
          nonce: nonce.toInt(),
          maxGas: quote.gasLimit!.toInt(),
          maxFeePerGas: EtherAmount.inWei(quote.maxFeePerGas!),
          maxPriorityFeePerGas: EtherAmount.inWei(quote.maxPriorityFeePerGas!),
        ),
        config.chainId!,
      ),
    );
  }

  void _validateFee(ChainFeeEstimate fee) {
    if (fee.chainId != config.id ||
        fee.gasLimit == null ||
        fee.maxFeePerGas == null ||
        fee.maxPriorityFeePerGas == null ||
        fee.gasLimit! <= BigInt.zero ||
        fee.gasLimit! > BigInt.from(36000000) ||
        fee.maxFeePerGas! < BigInt.from(config.minimumGasPrice) ||
        fee.maxPriorityFeePerGas! < BigInt.zero ||
        fee.maxPriorityFeePerGas! > fee.maxFeePerGas! ||
        fee.maxFee != fee.gasLimit! * fee.maxFeePerGas!) {
      throw StateError('Invalid network fee. Request a new estimate.');
    }
  }

  Future<Uint8List> _keyForAccount(ChainAccount account) async {
    final current = await getAccount();
    if (!current.canSign ||
        !_sameAddress(current.address, account.address) ||
        current.rootWalletId != account.rootWalletId)
      throw StateError('The selected wallet changed. Review again.');
    final key = EvmKeyService.derivePrivateKey(await _mnemonicReader());
    if (!_sameAddress(EthPrivateKey(key).address.hex, account.address)) {
      key.fillRange(0, key.length, 0);
      throw StateError(
        'Recovery phrase does not match the selected EVM account.',
      );
    }
    return key;
  }

  @override
  Future<SignedChainTransaction> signTransaction(
    PreparedChainTransaction transaction,
  ) async {
    _checkRequest(transaction.request);
    _validateFee(transaction.fee);
    await rpc.verifyNetwork();
    final payload = transaction.payload;
    if (payload is! _EvmPayload || payload.chainId != config.chainId) {
      throw StateError('Prepared transaction belongs to a different network.');
    }
    final intended = _transfer(transaction.request);
    final tx = payload.transaction;
    if (tx.from != intended.from ||
        tx.to != intended.to ||
        tx.value != intended.value ||
        bytesToHex(tx.data!) != bytesToHex(intended.data!) ||
        tx.maxGas != transaction.fee.gasLimit!.toInt() ||
        tx.maxFeePerGas!.getInWei != transaction.fee.maxFeePerGas ||
        tx.maxPriorityFeePerGas!.getInWei !=
            transaction.fee.maxPriorityFeePerGas) {
      throw StateError(
        'Transaction changed after review. Request a new estimate.',
      );
    }
    await _checkFunds(transaction.request, transaction.fee);
    final pendingNonce = _quantity(
      await rpc.call('eth_getTransactionCount', [
        transaction.request.account.address,
        'pending',
      ]),
    );
    if (pendingNonce != BigInt.from(tx.nonce!)) {
      throw StateError(
        'Account activity changed. Request a new transaction preview.',
      );
    }
    final key = await _keyForAccount(transaction.request.account);
    try {
      // web3dart 2.x returns signed RLP without EIP-2718's type byte.
      final bytes = prependTransactionType(
        2,
        signTransactionRaw(tx, EthPrivateKey(key), chainId: config.chainId),
      );
      final hash = bytesToHex(keccak256(bytes), include0x: true);
      _signedEnvelopes[hash] = transaction;
      return SignedChainTransaction(
        prepared: transaction,
        encoded: bytesToHex(bytes, include0x: true),
        transactionHash: hash,
      );
    } finally {
      key.fillRange(0, key.length, 0);
    }
  }

  @override
  Future<String> broadcastTransaction(
    SignedChainTransaction transaction,
  ) async {
    final payload = transaction.prepared.payload;
    if (payload is! _EvmPayload || payload.chainId != config.chainId)
      throw StateError('Wrong transaction network.');
    final account = await getAccount();
    if (!account.canSign ||
        !_sameAddress(
          account.address,
          transaction.prepared.request.account.address,
        ) ||
        account.rootWalletId !=
            transaction.prepared.request.account.rootWalletId) {
      throw StateError('The selected wallet changed. Review again.');
    }
    await rpc.verifyNetwork();
    final hash = bytesToHex(
      keccak256(hexToBytes(transaction.encoded)),
      include0x: true,
    );
    if (transaction.transactionHash != hash ||
        !identical(_signedEnvelopes[hash], transaction.prepared)) {
      throw StateError(
        'Signed transaction changed or was not approved by this adapter.',
      );
    }
    final nonceKey =
        '${account.address.toLowerCase()}:${payload.transaction.nonce}';
    if (_broadcasting.contains(nonceKey))
      throw StateError('This transaction is already being submitted.');
    final previous = _broadcastNonces[nonceKey];
    if (previous != null) {
      if (previous == hash) return hash;
      throw StateError(
        'A transaction already uses this nonce. Check its status first.',
      );
    }
    _broadcasting.add(nonceKey);
    _broadcastNonces[nonceKey] = hash;
    _tracked[hash] = transaction.prepared.request;
    try {
      final submitted = await rpc.call('eth_sendRawTransaction', [
        transaction.encoded,
      ]);
      if (submitted is! String || submitted.toLowerCase() != hash) {
        throw const EvmRpcException(
          'Network returned an unexpected transaction hash. Check activity before sending again.',
        );
      }
      return hash;
    } finally {
      _broadcasting.remove(nonceKey);
    }
  }

  Future<BigInt?> _finalizedHead() async {
    if (config.deterministicFinality) return null;
    try {
      final block = await rpc.call('eth_getBlockByNumber', [
        'finalized',
        false,
      ]);
      return block is Map && block['number'] != null
          ? _quantity(block['number'])
          : null;
    } on EvmNetworkMismatch {
      rethrow;
    } on EvmRpcException {
      return null;
    }
  }

  ChainTransactionStatus _receiptStatus(
    Map<dynamic, dynamic>? receipt, {
    BigInt? finalizedHead,
  }) {
    if (receipt == null || receipt['blockNumber'] == null)
      return ChainTransactionStatus.pending;
    if (!config.deterministicFinality) {
      if (finalizedHead == null) return ChainTransactionStatus.unknown;
      if (_quantity(receipt['blockNumber']) > finalizedHead)
        return ChainTransactionStatus.pending;
    }
    if (receipt['status'] == '0x0') return ChainTransactionStatus.failed;
    if (receipt['status'] == '0x1') return ChainTransactionStatus.finalSuccess;
    return ChainTransactionStatus.unknown;
  }

  Future<DateTime?> _timestamp(dynamic blockNumber) async {
    if (blockNumber == null) return null;
    final block = await rpc.call('eth_getBlockByNumber', [blockNumber, false]);
    if (block is! Map || block['timestamp'] == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      _quantity(block['timestamp']).toInt() * 1000,
      isUtc: true,
    );
  }

  @override
  Future<ChainActivity?> getTransaction(
    ChainAccount account,
    String hash,
  ) async {
    _checkAccount(account);
    if (!RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(hash))
      throw const FormatException('Invalid transaction hash.');
    final tx = await rpc.call('eth_getTransactionByHash', [hash]);
    final receiptValue = await rpc.call('eth_getTransactionReceipt', [hash]);
    final receipt = receiptValue is Map ? receiptValue : null;
    final trackedRequest = _tracked[hash];
    final request =
        trackedRequest != null && _belongsTo(trackedRequest, account)
        ? trackedRequest
        : null;
    if (tx is! Map) {
      if (request == null) return null;
      return ChainActivity(
        chainId: config.id,
        hash: hash,
        from: request.account.address,
        to: request.to,
        asset: request.asset,
        amount: request.amount,
        status: ChainTransactionStatus.unknown,
      );
    }
    var asset = request?.asset ?? nativeAsset;
    var amount = request?.amount ?? BigInt.zero;
    var to = request?.to ?? (tx['to'] as String? ?? '');
    final from = tx['from'] as String;
    final input = tx['input'] as String? ?? '0x';
    if (request == null &&
        RegExp(r'^0xa9059cbb0{24}[0-9a-fA-F]{104}$').hasMatch(input) &&
        tx['to'] != null) {
      asset = await importToken(tx['to'] as String);
      to = '0x${input.substring(34, 74)}';
      amount = BigInt.parse(input.substring(74), radix: 16);
    } else if (request == null) {
      final raw = _quantity(tx['value'] ?? '0x0');
      asset = _nativeHistoryAsset(raw);
      amount = raw ~/ BigInt.from(10).pow(config.feeDecimals - asset.decimals);
    }
    if (!_sameAddress(from, account.address) &&
        !_sameAddress(to, account.address))
      return null;
    final fee =
        receipt?['gasUsed'] != null && receipt?['effectiveGasPrice'] != null
        ? _quantity(receipt!['gasUsed']) *
              _quantity(receipt['effectiveGasPrice'])
        : null;
    return ChainActivity(
      chainId: config.id,
      hash: hash,
      from: from,
      to: to,
      asset: asset,
      amount: amount,
      status: _receiptStatus(receipt, finalizedHead: await _finalizedHead()),
      fee: fee,
      timestamp: await _timestamp(receipt?['blockNumber']),
    );
  }

  bool _belongsTo(ChainTransferRequest request, ChainAccount account) =>
      request.account.rootWalletId == account.rootWalletId &&
      request.account.chainId == account.chainId &&
      _sameAddress(request.account.address, account.address);

  ChainAsset _nativeHistoryAsset(BigInt raw) {
    final scale = BigInt.from(
      10,
    ).pow(config.feeDecimals - nativeAsset.decimals);
    if (raw % scale == BigInt.zero) return nativeAsset;
    // Preserve sub-micro USDC movements exactly rather than rendering them as zero.
    return ChainAsset(
      chainId: config.id,
      symbol: config.feeSymbol,
      name: config.feeSymbol,
      decimals: config.feeDecimals,
      rawBalance: BigInt.zero,
      isFeeAsset: true,
    );
  }

  @override
  Future<List<ChainActivity>> getActivity(
    ChainAccount account, {
    List<ChainAsset> tokens = const [],
    List<String> trackedHashes = const [],
  }) async {
    _checkAccount(account);
    final latest = _quantity(await rpc.call('eth_blockNumber', [])).toInt();
    final start = latest >= historyBlockWindow
        ? latest - historyBlockWindow + 1
        : 0;
    final emitters = <String, ChainAsset>{
      if (config.nativeTransferEmitter != null)
        config.nativeTransferEmitter!: nativeAsset,
      for (final token in tokens)
        if (token.contractAddress != null && !_isNativeAlias(token))
          token.contractAddress!: token,
    };
    final addressTopic =
        '0x${account.address.substring(2).toLowerCase().padLeft(64, '0')}';
    final logs = <String, Map<dynamic, dynamic>>{};
    for (final entry in emitters.entries) {
      _checkAsset(entry.value);
      final range = config.maxLogBlockRange;
      for (var first = start; first <= latest; first += range) {
        final last = first + range - 1 < latest ? first + range - 1 : latest;
        final responses = await Future.wait([
          for (final topics in [
            [_transferTopic, addressTopic],
            [_transferTopic, null, addressTopic],
          ])
            rpc.call('eth_getLogs', [
              {
                'address': entry.key,
                'fromBlock': _hex(BigInt.from(first)),
                'toBlock': _hex(BigInt.from(last)),
                'topics': topics,
              },
            ]),
        ]);
        for (final result in responses) {
          if (result is! List || result.length > 5000)
            throw const EvmRpcException(
              'Activity response is invalid or too large.',
            );
          for (final item in result) {
            if (item is Map &&
                item['removed'] != true &&
                item['transactionHash'] is String &&
                item['logIndex'] is String) {
              logs['${item['transactionHash']}:${item['logIndex']}'] = item;
            }
          }
        }
      }
    }
    final activities = <ChainActivity>[];
    final receipts = <String, Map<dynamic, dynamic>?>{};
    final times = <String, DateTime?>{};
    final finalizedHead = await _finalizedHead();
    for (final log in logs.values) {
      final topics = log['topics'];
      if (topics is! List ||
          topics.length != 3 ||
          topics[0] != _transferTopic ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(topics[1].toString()) ||
          !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(topics[2].toString()))
        continue;
      final from = '0x${(topics[1] as String).substring(26)}';
      final to = '0x${(topics[2] as String).substring(26)}';
      if (!_sameAddress(from, account.address) &&
          !_sameAddress(to, account.address))
        continue;
      final emitter = (log['address'] as String).toLowerCase();
      final matches = emitters.entries.where(
        (entry) => entry.key.toLowerCase() == emitter,
      );
      if (matches.isEmpty) continue;
      final raw = _quantity(log['data']);
      final nativeEvent =
          config.nativeTransferEmitter?.toLowerCase() == emitter;
      final asset = nativeEvent
          ? _nativeHistoryAsset(raw)
          : matches.first.value;
      final amount = nativeEvent
          ? raw ~/ BigInt.from(10).pow(config.feeDecimals - asset.decimals)
          : raw;
      final hash = log['transactionHash'] as String;
      if (!receipts.containsKey(hash)) {
        final value = await rpc.call('eth_getTransactionReceipt', [hash]);
        receipts[hash] = value is Map ? value : null;
      }
      final receipt = receipts[hash];
      final block = log['blockNumber'] as String;
      if (!times.containsKey(block)) times[block] = await _timestamp(block);
      activities.add(
        ChainActivity(
          chainId: config.id,
          hash: hash,
          from: from,
          to: to,
          asset: asset,
          amount: amount,
          status: _receiptStatus(receipt, finalizedHead: finalizedHead),
          timestamp: times[block],
          logIndex: _quantity(log['logIndex']).toInt(),
          fee:
              _sameAddress(from, account.address) &&
                  receipt?['gasUsed'] != null &&
                  receipt?['effectiveGasPrice'] != null
              ? _quantity(receipt!['gasUsed']) *
                    _quantity(receipt['effectiveGasPrice'])
              : null,
        ),
      );
    }
    final covered = activities.map((activity) => activity.hash).toSet();
    for (final hash in {
      ..._tracked.entries
          .where((entry) => _belongsTo(entry.value, account))
          .map((entry) => entry.key),
      ...trackedHashes,
    }) {
      if (!covered.contains(hash)) {
        final activity = await getTransaction(account, hash);
        if (activity != null) activities.add(activity);
      }
    }
    final now = DateTime.now();
    activities.sort((a, b) {
      final timeOrder = (b.timestamp ?? now).compareTo(a.timestamp ?? now);
      return timeOrder != 0
          ? timeOrder
          : (b.logIndex ?? -1).compareTo(a.logIndex ?? -1);
    });
    return activities;
  }

  @override
  Future<Uint8List> signMessage(Uint8List message) async {
    final account = await getAccount();
    final key = await _keyForAccount(account);
    try {
      return EthPrivateKey(key).signPersonalMessageToUint8List(message);
    } finally {
      key.fillRange(0, key.length, 0);
    }
  }

  /// Service capability only. Future dapp callers must obtain an explicit,
  /// human-readable review before invoking any signing method.
  Future<String> signTypedData(Map<String, dynamic> data) async {
    final domain = data['domain'];
    final suppliedChain = domain is Map ? domain['chainId'] : null;
    if (suppliedChain == null ||
        BigInt.tryParse(suppliedChain.toString()) !=
            BigInt.from(config.chainId!)) {
      throw StateError(
        'Typed data must declare the selected network in its domain.',
      );
    }
    if (jsonEncode(data).length > 65536)
      throw const FormatException('Typed data is too large.');
    final account = await getAccount();
    final key = await _keyForAccount(account);
    try {
      return EthSigUtil.signTypedData(
        privateKeyInBytes: key,
        jsonData: jsonEncode(data),
        version: TypedDataVersion.V4,
      );
    } finally {
      key.fillRange(0, key.length, 0);
    }
  }
}

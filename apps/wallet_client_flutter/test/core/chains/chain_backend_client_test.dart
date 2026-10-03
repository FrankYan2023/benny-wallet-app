import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/arc_chain_config.dart';
import 'package:wallet_client_flutter/core/chains/chain_backend_client.dart';
import 'package:wallet_client_flutter/core/chains/chain_models.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_rpc.dart';

const account = ChainAccount(
  rootWalletId: 'owner',
  chainId: 'arc-mainnet',
  address: '0x0000000000000000000000000000000000000001',
);
Map<String, dynamic> proof(DateTime now) {
  final nonce = 'a' * 48,
      expires = now.add(const Duration(minutes: 5)).toIso8601String();
  return {
    'nonce': nonce,
    'expiresAt': expires,
    'ownerAddress': account.rootWalletId,
    'chainId': account.chainId,
    'address': account.address,
    'message': [
      'Benny Wallet account binding',
      'Owner: owner',
      'Network: arc-mainnet',
      'Address: ${account.address}',
      'Nonce: $nonce',
      'Expires: $expires',
      'This proof links public accounts. It does not authorize a transfer.',
    ].join('\n'),
  };
}

void main() {
  test('mainnet is default and has no testnet gas-floor assumption', () {
    expect(configuredArcChain.chainId, 5042);
    expect(arcMainnetConfig.minimumGasPrice, 0);
    expect(useDirectTestnetRpc, false);
    expect(arcMainnetConfig.namespace, 'eip155:5042');
  });
  test(
    'authentication proof rejects arbitrary signing, changed owner, network and expiry',
    () {
      final now = DateTime.utc(2026, 9, 26),
          valid = proof(DateTime.utc(2026, 9, 26));
      expect(validateAccountProof(valid, account, now: now), valid['message']);
      for (final changed in [
        {...valid, 'message': 'Transfer my funds'},
        {...valid, 'chainId': 'arc-testnet'},
        {...valid, 'ownerAddress': 'foreign'},
        {...valid, 'address': '0xdead'},
        {...valid, 'nonce': 'short'},
        {
          ...valid,
          'expiresAt': now
              .subtract(const Duration(seconds: 1))
              .toIso8601String(),
        },
      ]) {
        expect(
          () => validateAccountProof(changed, account, now: now),
          throwsA(isA<EvmRpcException>()),
        );
      }
    },
  );
  test(
    'backend uses only API host, auth header and expected chain; verifies chain before reads',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              final body = options.data as Map;
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'jsonrpc': '2.0',
                    'id': body['id'],
                    'result': body['method'] == 'eth_chainId'
                        ? '0x13b2'
                        : '0x7',
                  },
                ),
              );
            },
          ),
        );
      final client = ChainBackendClient(
        config: arcMainnetConfig,
        baseUrl: 'https://api.example.test',
        dio: dio,
        accountReader: () async => account,
        headersReader: () async => {'Authorization': 'Bearer fixture'},
        proofSigner: (_) async => throw StateError('No proof for reads'),
        guard: () {},
      );
      expect(
        await BackendEvmRpc(
          client,
        ).call('eth_getBalance', [account.address, 'latest']),
        '0x7',
      );
      expect(requests.map((r) => r.uri.host), everyElement('api.example.test'));
      expect(
        requests.map((r) => r.headers['X-Chain-Id']),
        everyElement('5042'),
      );
      expect(
        requests.map((r) => r.headers['Authorization']),
        everyElement('Bearer fixture'),
      );
      expect(requests.every((r) => !r.followRedirects), true);
    },
  );
  test('wrong backend network prevents broadcast', () async {
    var calls = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            calls++;
            final body = options.data as Map;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'jsonrpc': '2.0', 'id': body['id'], 'result': '0x1'},
              ),
            );
          },
        ),
      );
    final client = ChainBackendClient(
      config: arcMainnetConfig,
      baseUrl: 'https://api.example.test',
      dio: dio,
      accountReader: () async => account,
      headersReader: () async => {},
      proofSigner: (_) async => '',
      guard: () {},
    );
    await expectLater(
      BackendEvmRpc(client).call('eth_sendRawTransaction', ['0xfixture']),
      throwsA(isA<EvmNetworkMismatch>()),
    );
    expect(calls, 1);
  });
  test('ambiguous send is attempted once and never fails over', () async {
    var sends = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.endsWith('/account')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'account': {'address': account.address},
                  },
                ),
              );
              return;
            }
            final body = options.data as Map;
            if (body['method'] == 'eth_sendRawTransaction') {
              sends++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.receiveTimeout,
                ),
              );
              return;
            }
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'jsonrpc': '2.0', 'id': body['id'], 'result': '0x13b2'},
              ),
            );
          },
        ),
      );
    final client = ChainBackendClient(
      config: arcMainnetConfig,
      baseUrl: 'https://api.example.test',
      dio: dio,
      accountReader: () async => account,
      headersReader: () async => {},
      proofSigner: (_) async => '',
      guard: () {},
    );
    await expectLater(
      BackendEvmRpc(client).call('eth_sendRawTransaction', ['0xfixture']),
      throwsA(isA<EvmRpcException>()),
    );
    expect(sends, 1);
  });
  test(
    'wallet switch while awaiting authentication prevents requests',
    () async {
      var unlocked = true, calls = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (_, _) {
              calls++;
            },
          ),
        );
      final client = ChainBackendClient(
        config: arcMainnetConfig,
        baseUrl: 'https://api.example.test',
        dio: dio,
        accountReader: () async => account,
        headersReader: () async {
          unlocked = false;
          return {};
        },
        proofSigner: (_) async => '',
        guard: () {
          if (!unlocked) throw StateError('Locked');
        },
      );
      await expectLater(client.rpc('eth_chainId', []), throwsStateError);
      expect(calls, 0);
    },
  );
  test('asset decoding retains exact balance and optional quote', () {
    final asset = ChainAsset.fromJson({
      'chainId': account.chainId,
      'symbol': 'USDC',
      'name': 'USDC',
      'decimals': 6,
      'rawBalance': '123456789123456789',
      'fiatPrice': 0.999,
    });
    expect(asset.rawBalance, BigInt.parse('123456789123456789'));
    expect(asset.fiatPrice, 0.999);
  });
  test(
    'history keeps distinct logs but replaces duplicate transaction summary',
    () {
      const hash = '0xhash';
      final asset = ChainAsset(
        chainId: account.chainId,
        symbol: 'USDC',
        name: 'USDC',
        decimals: 6,
        rawBalance: BigInt.zero,
      );
      ChainActivity item(int? index) => ChainActivity(
        chainId: account.chainId,
        hash: hash,
        from: 'from',
        to: 'to',
        asset: asset,
        amount: BigInt.one,
        status: ChainTransactionStatus.finalSuccess,
        logIndex: index,
      );
      final merged = mergeChainHistory([item(null), item(1), item(2), item(1)]);
      expect(merged.length, 2);
      expect(merged.map((e) => e.logIndex), [1, 2]);
    },
  );
  test(
    'transient read retries once with fresh headers and identical RPC payload',
    () async {
      var attempts = 0, headers = 0;
      final seen = <RequestOptions>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              seen.add(options);
              if (++attempts == 1) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.receiveTimeout,
                  ),
                );
              } else {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {'jsonrpc': '2.0', 'id': 1, 'result': '0x1'},
                  ),
                );
              }
            },
          ),
        );
      final client = ChainBackendClient(
        config: arcMainnetConfig,
        baseUrl: 'https://example.test',
        dio: dio,
        accountReader: () async => account,
        headersReader: () async => {
          'Authorization': 'Bearer fixture-${++headers}',
        },
        proofSigner: (_) async => '',
        guard: () {},
        retryDelay: (_) async {},
      );
      expect(
        await client.rpc('eth_getBalance', [account.address, 'latest']),
        '0x1',
      );
      expect(attempts, 2);
      expect(headers, 2);
      expect(seen[0].data, seen[1].data);
      expect(seen[1].headers['Authorization'], 'Bearer fixture-2');
    },
  );

  test(
    'reads honor short Retry-After and never retry long throttles or permanent errors',
    () async {
      for (final (status, after, expected) in [
        (429, '1', 2),
        (429, '30', 1),
        (401, null, 1),
        (403, null, 1),
        (409, null, 1),
        (503, null, 2),
      ]) {
        var attempts = 0;
        final delays = <Duration>[];
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                attempts++;
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.badResponse,
                    response: Response(
                      requestOptions: options,
                      statusCode: status,
                      data: {
                        'error': status == 409 ? 'network_mismatch' : 'fixture',
                      },
                      headers: Headers.fromMap({
                        if (after != null) 'retry-after': [after],
                      }),
                    ),
                  ),
                );
              },
            ),
          );
        final client = ChainBackendClient(
          config: arcMainnetConfig,
          baseUrl: 'https://example.test',
          dio: dio,
          accountReader: () async => account,
          headersReader: () async => {},
          proofSigner: (_) async => '',
          guard: () {},
          retryDelay: (delay) async {
            delays.add(delay);
          },
        );
        await expectLater(
          client.request('/v1/chains/arc/config'),
          throwsA(isA<EvmRpcException>()),
        );
        expect(attempts, expected, reason: '$status / $after');
        if (after == '1') expect(delays, [const Duration(seconds: 1)]);
      }
    },
  );

  test(
    'token import and account verification writes are never retried',
    () async {
      for (final path in [
        '/v1/chains/arc/tokens',
        '/v1/chains/arc/account/verify',
        '/v1/chains/arc/account/challenge',
      ]) {
        var attempts = 0;
        final dio = Dio()
          ..interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                attempts++;
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.receiveTimeout,
                  ),
                );
              },
            ),
          );
        final client = ChainBackendClient(
          config: arcMainnetConfig,
          baseUrl: 'https://example.test',
          dio: dio,
          accountReader: () async => account,
          headersReader: () async => {},
          proofSigner: (_) async => '',
          guard: () {},
          retryDelay: (_) async {},
        );
        await expectLater(
          client.request(path, body: {'fixture': true}),
          throwsA(isA<EvmRpcException>()),
        );
        expect(attempts, 1);
      }
    },
  );

  test(
    'a wallet switch during retry delay stops before the second request',
    () async {
      var attempts = 0, changed = false;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              attempts++;
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionTimeout,
                ),
              );
            },
          ),
        );
      final client = ChainBackendClient(
        config: arcMainnetConfig,
        baseUrl: 'https://example.test',
        dio: dio,
        accountReader: () async => account,
        headersReader: () async => {},
        proofSigner: (_) async => '',
        guard: () {
          if (changed) throw StateError('session changed');
        },
        retryDelay: (_) async {
          changed = true;
        },
      );
      await expectLater(
        client.request('/v1/chains/arc/config'),
        throwsStateError,
      );
      expect(attempts, 1);
    },
  );
}

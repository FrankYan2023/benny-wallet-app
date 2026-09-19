import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/chains/evm/evm_rpc.dart';

void main() {
  test('wrong chain ID fails closed without reading or broadcasting', () async {
    final methods = <String>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final request = options.data as Map;
            methods.add(request['method'] as String);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'jsonrpc': '2.0', 'id': request['id'], 'result': '0x1'},
              ),
            );
          },
        ),
      );
    final rpc = DioEvmRpc(
      chainId: 5042002,
      urls: ['https://example.org'],
      dio: dio,
    );
    await expectLater(
      rpc.call('eth_getBalance', ['0x0', 'latest']),
      throwsA(isA<EvmNetworkMismatch>()),
    );
    await expectLater(
      rpc.call('eth_sendRawTransaction', ['secret-envelope']),
      throwsA(isA<EvmNetworkMismatch>()),
    );
    expect(methods, everyElement('eth_chainId'));
  });
  test('transport failure falls back to another verified endpoint', () async {
    final requests = <String>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final request = options.data as Map;
            requests.add('${options.uri.host}:${request['method']}');
            if (options.uri.host == 'primary.example') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.connectionError,
                ),
              );
            } else {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {
                    'jsonrpc': '2.0',
                    'id': request['id'],
                    'result': request['method'] == 'eth_chainId'
                        ? '0x4cef52'
                        : '0x123',
                  },
                ),
              );
            }
          },
        ),
      );
    final rpc = DioEvmRpc(
      chainId: 5042002,
      urls: ['https://primary.example', 'https://fallback.example'],
      dio: dio,
    );
    expect(await rpc.call('eth_getBalance', ['0x0', 'latest']), '0x123');
    expect(requests, [
      'primary.example:eth_chainId',
      'fallback.example:eth_chainId',
      'fallback.example:eth_getBalance',
    ]);
  });
  test(
    'broadcast response loss is not retried or echoed in error text',
    () async {
      var broadcasts = 0;
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final request = options.data as Map;
              if (request['method'] == 'eth_chainId') {
                handler.resolve(
                  Response(
                    requestOptions: options,
                    data: {
                      'jsonrpc': '2.0',
                      'id': request['id'],
                      'result': '0x4cef52',
                    },
                  ),
                );
              } else {
                broadcasts++;
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.receiveTimeout,
                    message: 'private-provider-credential secret-envelope',
                  ),
                );
              }
            },
          ),
        );
      final rpc = DioEvmRpc(
        chainId: 5042002,
        urls: ['https://primary.example', 'https://fallback.example'],
        dio: dio,
      );
      try {
        await rpc.call('eth_sendRawTransaction', ['secret-envelope']);
        fail('Expected response-loss failure');
      } on EvmRpcException catch (error) {
        expect(error.toString(), contains('Check transaction status'));
        expect(error.toString(), isNot(contains('secret-envelope')));
        expect(
          error.toString(),
          isNot(contains('private-provider-credential')),
        );
      }
      expect(broadcasts, 1);
    },
  );
  test('RPC response must match the request id', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {'jsonrpc': '2.0', 'id': -1, 'result': '0x4cef52'},
              ),
            );
          },
        ),
      );
    await expectLater(
      DioEvmRpc(
        chainId: 5042002,
        urls: ['https://example.org'],
        dio: dio,
      ).verifyNetwork(),
      throwsA(isA<EvmRpcException>()),
    );
  });
}

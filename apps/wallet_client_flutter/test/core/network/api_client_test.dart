import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_client_flutter/core/network/api_client.dart';
import 'package:wallet_client_flutter/core/network/wallet_auth_api_client.dart';

void main() {
  group('BackendApiClient', () {
    test('maps connection timeout errors to a friendly message', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message:
                    'The request connection took longer than 0:00:10.000000 and it was aborted.',
              ),
            );
          },
        ),
      );

      final client = BackendApiClient(dio: dio);

      await expectLater(
        client.getPortfolio('11111111111111111111111111111111'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('Couldn\'t reach the server'),
              isNot(contains('RequestOptions')),
              isNot(contains('connectTimeout')),
            ),
          ),
        ),
      );
    });

    test('uses endpoint fallback text for server errors', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 502,
                  data: {'message': 'helius RPC timed out after 4000ms'},
                ),
              ),
            );
          },
        ),
      );

      final client = BackendApiClient(dio: dio);

      await expectLater(
        client.getPortfolio('11111111111111111111111111111111'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            allOf(
              contains('Unable to load your wallet right now.'),
              isNot(contains('helius')),
            ),
          ),
        ),
      );
    });

    test('retries read requests against a fallback backend', () async {
      final primaryDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      primaryDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'The connection errored: Connection reset by peer',
              ),
            );
          },
        ),
      );
      final fallbackDio = Dio(BaseOptions(baseUrl: 'https://fallback.test'));
      fallbackDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                data: {'address': 'fallback-address'},
              ),
            );
          },
        ),
      );

      final client = BackendApiClient(
        dio: primaryDio,
        fallbackDios: [fallbackDio],
      );

      final payload = await client.getPortfolio(
        '11111111111111111111111111111111',
      );

      expect(payload['address'], 'fallback-address');
    });
  });

  group('WalletAuthApiClient', () {
    test('maps connection timeout errors to a friendly message', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                message:
                    'The request connection took longer than 0:00:10.000000 and it was aborted.',
              ),
            );
          },
        ),
      );

      final client = WalletAuthApiClient(dio: dio);

      await expectLater(
        client.createChallenge('11111111111111111111111111111111'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Couldn\'t reach the server'),
              isNot(contains('RequestOptions')),
              isNot(contains('connectTimeout')),
            ),
          ),
        ),
      );
    });

    test('retries auth requests against a fallback backend', () async {
      final primaryDio = Dio(BaseOptions(baseUrl: 'https://api.test'));
      primaryDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'The connection errored: Connection reset by peer',
              ),
            );
          },
        ),
      );
      final fallbackDio = Dio(BaseOptions(baseUrl: 'https://fallback.test'));
      fallbackDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                data: {
                  'challenge': 'challenge',
                  'expiresAt': '2026-05-23T21:00:00Z',
                  'message': 'Sign in',
                  'ownerAddress': '11111111111111111111111111111111',
                },
              ),
            );
          },
        ),
      );

      final client = WalletAuthApiClient(
        dio: primaryDio,
        fallbackDios: [fallbackDio],
      );

      final challenge = await client.createChallenge(
        '11111111111111111111111111111111',
      );

      expect(challenge.challenge, 'challenge');
    });
  });
}

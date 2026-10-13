import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'backend_endpoint_fallback.dart';

class WalletAuthChallenge {
  const WalletAuthChallenge({
    required this.challenge,
    required this.expiresAt,
    required this.message,
    required this.ownerAddress,
  });

  final String challenge;
  final DateTime expiresAt;
  final String message;
  final String ownerAddress;

  factory WalletAuthChallenge.fromJson(Map<String, dynamic> json) {
    return WalletAuthChallenge(
      challenge: json['challenge'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      message: json['message'] as String? ?? '',
      ownerAddress: json['ownerAddress'] as String? ?? '',
    );
  }
}

class WalletAuthSession {
  const WalletAuthSession({
    required this.accessToken,
    required this.expiresAt,
    required this.ownerAddress,
    required this.tokenType,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String ownerAddress;
  final String tokenType;

  factory WalletAuthSession.fromJson(Map<String, dynamic> json) {
    return WalletAuthSession(
      accessToken: json['accessToken'] as String? ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
      ownerAddress: json['ownerAddress'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}

const _defaultWalletAuthTimeout = Duration(seconds: 20);

class WalletAuthApiClient {
  WalletAuthApiClient({Dio? dio, List<Dio>? fallbackDios})
    : _dio =
          dio ??
          createBackendDio(
            baseUrl: AppConstants.apiBaseUrl,
            timeout: _defaultWalletAuthTimeout,
          ),
      _fallbackDios =
          fallbackDios ??
          (dio == null
              ? buildBackendFallbackDios(timeout: _defaultWalletAuthTimeout)
              : const []);

  final Dio _dio;
  final List<Dio> _fallbackDios;

  Future<WalletAuthChallenge> createChallenge(String ownerAddress) async {
    try {
      final response = await _requestWithFallback(
        (dio) => dio.post<Map<String, dynamic>>(
          '/v1/auth/challenge',
          data: {'ownerAddress': ownerAddress},
        ),
      );
      return WalletAuthChallenge.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw StateError(
        _messageFromDio(error, 'Unable to start wallet authentication.'),
      );
    }
  }

  Future<WalletAuthSession> verifyChallenge({
    required String ownerAddress,
    required String challenge,
    required String signature,
  }) async {
    try {
      final response = await _requestWithFallback(
        (dio) => dio.post<Map<String, dynamic>>(
          '/v1/auth/verify',
          data: {
            'ownerAddress': ownerAddress,
            'challenge': challenge,
            'signature': signature,
          },
        ),
      );
      return WalletAuthSession.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw StateError(
        _messageFromDio(error, 'Unable to verify the wallet signature.'),
      );
    }
  }

  Future<Response<Map<String, dynamic>>> _requestWithFallback(
    Future<Response<Map<String, dynamic>>> Function(Dio dio) request,
  ) {
    return requestWithBackendFallback<Map<String, dynamic>>(
      primary: _dio,
      fallbacks: _fallbackDios,
      request: request,
    );
  }

  String _messageFromDio(DioException error, String fallback) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 429) {
      return 'The network is busy right now. Please try again.';
    }
    if (statusCode != null && statusCode >= 500) {
      return fallback;
    }

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
        return 'Couldn\'t reach the server. Check your connection and try again.';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server is taking longer than expected. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Couldn\'t verify the server connection. Please try again later.';
      case DioExceptionType.cancel:
        return 'The request was cancelled. Please try again.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    return fallback;
  }
}

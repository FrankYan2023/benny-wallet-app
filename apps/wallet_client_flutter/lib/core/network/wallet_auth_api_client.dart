import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

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

class WalletAuthApiClient {
  WalletAuthApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConstants.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<WalletAuthChallenge> createChallenge(String ownerAddress) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/challenge',
        data: {'ownerAddress': ownerAddress},
      );
      return WalletAuthChallenge.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw StateError(_messageFromDio(error, 'Unable to start wallet authentication.'));
    }
  }

  Future<WalletAuthSession> verifyChallenge({
    required String ownerAddress,
    required String challenge,
    required String signature,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/verify',
        data: {
          'ownerAddress': ownerAddress,
          'challenge': challenge,
          'signature': signature,
        },
      );
      return WalletAuthSession.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw StateError(_messageFromDio(error, 'Unable to verify the wallet signature.'));
    }
  }

  String _messageFromDio(DioException error, String fallback) {
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

    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }
}
import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

List<Dio> buildBackendFallbackDios({required Duration timeout}) {
  return _fallbackBaseUrls()
      .map((baseUrl) => createBackendDio(baseUrl: baseUrl, timeout: timeout))
      .toList(growable: false);
}

Dio createBackendDio({required String baseUrl, required Duration timeout}) {
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    ),
  );
}

Future<Response<T>> requestWithBackendFallback<T>({
  required Dio primary,
  required List<Dio> fallbacks,
  required Future<Response<T>> Function(Dio dio) request,
}) async {
  try {
    return await request(primary);
  } on DioException catch (error) {
    if (fallbacks.isEmpty || !isBackendFallbackCandidate(error)) {
      rethrow;
    }
  }

  DioException? lastError;
  for (final fallback in fallbacks) {
    try {
      return await request(fallback);
    } on DioException catch (error) {
      if (!isBackendFallbackCandidate(error)) {
        rethrow;
      }
      lastError = error;
    }
  }

  throw lastError!;
}

bool isBackendFallbackCandidate(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return true;
    case DioExceptionType.badResponse:
      return _isEdgeConnectivityStatus(error.response?.statusCode);
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return _looksLikeConnectionReset(error.message);
  }
}

List<String> _fallbackBaseUrls() {
  final explicit = _parseBaseUrls(AppConstants.apiFallbackBaseUrls);
  final fallbackUrls = explicit.isNotEmpty
      ? explicit
      : _defaultFallbackBaseUrls();
  final primary = _normalizeBaseUrl(AppConstants.apiBaseUrl);

  return fallbackUrls
      .where((baseUrl) => _normalizeBaseUrl(baseUrl) != primary)
      .toList(growable: false);
}

List<String> _defaultFallbackBaseUrls() {
  if (_normalizeBaseUrl(AppConstants.apiBaseUrl) !=
      _normalizeBaseUrl(AppConstants.productionApiBaseUrl)) {
    return const [];
  }

  return const [AppConstants.productionApiFallbackBaseUrl];
}

List<String> _parseBaseUrls(String raw) {
  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.startsWith('https://'))
      .toSet()
      .toList(growable: false);
}

bool _isEdgeConnectivityStatus(int? statusCode) {
  return statusCode == 521 ||
      statusCode == 522 ||
      statusCode == 523 ||
      statusCode == 524;
}

bool _looksLikeConnectionReset(String? message) {
  final lower = message?.toLowerCase() ?? '';
  return lower.contains('connection reset') ||
      lower.contains('connection closed') ||
      lower.contains('broken pipe');
}

String _normalizeBaseUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.endsWith('/')) {
    return trimmed.substring(0, trimmed.length - 1);
  }
  return trimmed;
}

import 'package:dio/dio.dart';

abstract class EvmRpc {
  Future<void> verifyNetwork();
  Future<dynamic> call(String method, List<dynamic> params);
}

class EvmRpcException implements Exception {
  const EvmRpcException(this.message, {this.code});
  final String message;
  final int? code;
  @override
  String toString() => message;
}

class EvmNetworkMismatch extends EvmRpcException {
  const EvmNetworkMismatch()
    : super('RPC returned the wrong network. The operation was stopped.');
}

/// Every selected endpoint is checked against the configured signing chain.
/// Read failures can fail over; broadcasts are never retried automatically.
class DioEvmRpc implements EvmRpc {
  DioEvmRpc({required this.chainId, required List<String> urls, Dio? dio})
    : _urls = List.unmodifiable(urls),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ) {
    if (urls.isEmpty ||
        urls.any((url) => Uri.tryParse(url)?.scheme != 'https')) {
      throw ArgumentError('EVM RPC endpoints must use HTTPS.');
    }
  }
  final int chainId;
  final List<String> _urls;
  final Dio _dio;
  int _id = 0;
  int _selected = 0;

  Future<dynamic> _request(
    String url,
    String method,
    List<dynamic> params,
  ) async {
    final requestId = ++_id;
    final response = await _dio.post<dynamic>(
      url,
      data: {
        'jsonrpc': '2.0',
        'id': requestId,
        'method': method,
        'params': params,
      },
    );
    final body = response.data;
    if (body is! Map || body['id'] != requestId || body['jsonrpc'] != '2.0') {
      throw const EvmRpcException('Invalid response from the network.');
    }
    if (body['error'] is Map) {
      final error = body['error'] as Map;
      // Do not expose remote errors that may echo signing data or endpoint credentials.
      throw EvmRpcException(
        'Network rejected $method. Please review the transaction and retry.',
        code: error['code'] is int ? error['code'] as int : null,
      );
    }
    if (!body.containsKey('result'))
      throw const EvmRpcException('Missing network result.');
    return body['result'];
  }

  Future<void> _verify(String url) async {
    final actual = await _request(url, 'eth_chainId', []);
    if (actual is! String || BigInt.tryParse(actual) != BigInt.from(chainId)) {
      throw const EvmNetworkMismatch();
    }
  }

  @override
  Future<void> verifyNetwork() async {
    for (var offset = 0; offset < _urls.length; offset++) {
      final index = (_selected + offset) % _urls.length;
      try {
        await _verify(_urls[index]);
        _selected = index;
        return;
      } on DioException {
        if (offset == _urls.length - 1) {
          throw const EvmRpcException(
            'Unable to connect to the network. Try again shortly.',
          );
        }
      }
    }
  }

  @override
  Future<dynamic> call(String method, List<dynamic> params) async {
    await verifyNetwork();
    if (method == 'eth_sendRawTransaction') {
      // An interrupted response may still have submitted the transaction.
      try {
        return await _request(_urls[_selected], method, params);
      } on DioException {
        throw const EvmRpcException(
          'Submission response was interrupted. Check transaction status before sending again.',
        );
      }
    }
    for (var offset = 0; offset < _urls.length; offset++) {
      final index = (_selected + offset) % _urls.length;
      try {
        if (offset > 0) await _verify(_urls[index]);
        final result = await _request(_urls[index], method, params);
        _selected = index;
        return result;
      } on DioException {
        if (offset == _urls.length - 1) {
          throw const EvmRpcException(
            'Unable to read the network. Try again shortly.',
          );
        }
      }
    }
    throw const EvmRpcException('Network unavailable.');
  }
}

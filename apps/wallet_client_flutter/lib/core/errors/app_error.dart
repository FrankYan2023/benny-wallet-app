enum AppErrorType {
  network,
  rpc,
  validation,
  biometric,
  pin,
  sendTransaction,
  priceUnavailable,
  unknown,
}

class AppError implements Exception {
  const AppError({
    required this.type,
    required this.message,
    this.details,
  });

  final AppErrorType type;
  final String message;
  final Object? details;
}


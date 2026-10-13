import 'app_error.dart';

abstract final class ErrorMapper {
  static AppError fromObject(Object error) {
    if (error is AppError) {
      return error;
    }

    return AppError(
      type: AppErrorType.unknown,
      message: 'Something went wrong. Please try again.',
      details: error,
    );
  }
}


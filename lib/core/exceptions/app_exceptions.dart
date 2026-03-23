sealed class AppException implements Exception {
  AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause != null ? '$message (causa: $cause)' : message;
}

final class DatabaseException extends AppException {
  DatabaseException(super.message, [super.cause]);
}

final class ApiException extends AppException {
  ApiException(super.message, [super.cause]) : statusCode = null;

  final int? statusCode;

  ApiException.withStatus(super.message, this.statusCode, [super.cause]);
}

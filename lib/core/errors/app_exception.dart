/// Typed Domain Exceptions for Error Handling and User Feedback
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Database & Storage Exception
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code, super.originalError});
}

/// Network & API Integration Exception
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});
}

/// Backup & Restore Integrity Exception
class BackupException extends AppException {
  const BackupException(super.message, {super.code, super.originalError});
}

/// Validation & Parsing Exception
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.originalError});
}

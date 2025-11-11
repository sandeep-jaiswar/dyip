class ServerException implements Exception {}

class NetworkException implements Exception {}

class InvalidPhoneNumberException implements Exception {}

class InvalidOtpException implements Exception {}

class UserNotFoundException implements Exception {}

class SessionExpiredException implements Exception {}

class TooManyRequestsException implements Exception {}

class UnknownAuthException implements Exception {
  final String message;

  UnknownAuthException(this.message);
}

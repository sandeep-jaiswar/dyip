import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  // Store properties so Equatable can use them for comparisons
  final List<Object?> properties;

  const Failure([this.properties = const <Object?>[]]);

  @override
  List<Object?> get props => properties;
}

// General failures
class ServerFailure extends Failure {}

class NetworkFailure extends Failure {}

// Authentication failures
class InvalidPhoneNumberFailure extends Failure {}

class InvalidOtpFailure extends Failure {}

class UserNotFoundFailure extends Failure {}

class SessionExpiredFailure extends Failure {}

class TooManyRequestsFailure extends Failure {}

class UnknownAuthFailure extends Failure {
  final String message;

  const UnknownAuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  const VerifyOtpEvent({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object> get props => [verificationId, otp];
}

class LogoutEvent extends AuthEvent {}

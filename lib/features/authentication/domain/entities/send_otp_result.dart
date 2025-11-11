import 'package:equatable/equatable.dart';

/// Result for the sendOtp flow.
/// CodeSent indicates a verificationId was sent.
/// Initiated indicates the verification process started (no verificationId available yet).
abstract class SendOtpResult extends Equatable {
  const SendOtpResult();

  @override
  List<Object?> get props => [];
}

class CodeSent extends SendOtpResult {
  final String verificationId;
  const CodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

class Initiated extends SendOtpResult {
  const Initiated();

  @override
  List<Object?> get props => [];
}

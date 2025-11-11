import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

/// Result for the sendOtp flow.
/// CodeSent indicates a verificationId was sent.
/// Initiated indicates the verification process started (no verificationId available yet).
@immutable
abstract class SendOtpResult extends Equatable {
  const SendOtpResult();

  @override
  List<Object?> get props => [];
}

@immutable
class CodeSent extends SendOtpResult {
  final String verificationId;
  const CodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

@immutable
class Initiated extends SendOtpResult {
  const Initiated();

  @override
  List<Object?> get props => [];
}

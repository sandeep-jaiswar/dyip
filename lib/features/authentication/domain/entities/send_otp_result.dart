/// Result for the sendOtp flow.
/// CodeSent indicates a verificationId was sent.
/// Initiated indicates the verification process started (no verificationId available yet).
abstract class SendOtpResult {
  const SendOtpResult();
}

class CodeSent extends SendOtpResult {
  final String verificationId;
  const CodeSent(this.verificationId);
}

class Initiated extends SendOtpResult {
  const Initiated();
}

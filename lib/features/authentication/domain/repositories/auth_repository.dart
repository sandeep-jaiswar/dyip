import 'package:dartz/dartz.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';

abstract class AuthRepository {
  /// Send OTP to the given phone number
  Future<Either<Failure, SendOtpResult>> sendOtp(String phoneNumber);

  /// Verify the OTP and complete authentication
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String otp,
  });

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Get the current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}

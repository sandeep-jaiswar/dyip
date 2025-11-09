import 'package:dartz/dartz.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtp implements UseCase<User, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, User>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(
      verificationId: params.verificationId,
      otp: params.otp,
    );
  }
}

class VerifyOtpParams {
  final String verificationId;
  final String otp;

  VerifyOtpParams({required this.verificationId, required this.otp});
}

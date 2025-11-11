import 'package:dartz/dartz.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';

class SendOtp implements UseCase<SendOtpResult, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, SendOtpResult>> call(SendOtpParams params) async {
    return await repository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams {
  final String phoneNumber;

  SendOtpParams(this.phoneNumber);
}

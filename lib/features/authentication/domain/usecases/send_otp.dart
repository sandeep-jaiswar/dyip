import 'package:dartz/dartz.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';

class SendOtp implements UseCase<String, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(SendOtpParams params) async {
    return await repository.sendOtp(params.phoneNumber);
  }
}

class SendOtpParams {
  final String phoneNumber;

  SendOtpParams(this.phoneNumber);
}

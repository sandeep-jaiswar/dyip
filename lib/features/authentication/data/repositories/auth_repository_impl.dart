import 'package:dartz/dartz.dart';
import 'package:dyip/core/error/exceptions.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SendOtpResult>> sendOtp(String phoneNumber) async {
    try {
      final result = await remoteDataSource.sendOtp(phoneNumber);
      return Right(result);
    } on InvalidPhoneNumberException {
      return Left(InvalidPhoneNumberFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on TooManyRequestsException {
      return Left(TooManyRequestsFailure());
    } on UnknownAuthException catch (e) {
      return Left(UnknownAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final user = await remoteDataSource.verifyOtp(
        verificationId: verificationId,
        otp: otp,
      );
      return Right(user.toEntity());
    } on InvalidOtpException {
      return Left(InvalidOtpFailure());
    } on SessionExpiredException {
      return Left(SessionExpiredFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnknownAuthException catch (e) {
      return Left(UnknownAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on UnknownAuthException catch (e) {
      return Left(UnknownAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      if (user == null) return const Right(null);
      return Right(user.toEntity());
    } on UnknownAuthException catch (e) {
      return Left(UnknownAuthFailure(e.message));
    } catch (e) {
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel == null) return null;
      return userModel.toEntity();
    });
  }
}

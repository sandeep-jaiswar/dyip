import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/core/error/exceptions.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:dyip/features/authentication/data/models/user_model.dart';
import 'package:dyip/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('sendOtp', () {
    const testPhoneNumber = '+1234567890';
    const testVerificationId = 'test_verification_id';

    test(
      'should return verification ID when call to data source is successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.sendOtp(any()),
        ).thenAnswer((_) async => const CodeSent(testVerificationId));

        // act
        final result = await repository.sendOtp(testPhoneNumber);

        // assert
        expect(result, const Right(CodeSent(testVerificationId)));
        verify(() => mockRemoteDataSource.sendOtp(testPhoneNumber)).called(1);
      },
    );

    test(
      'should return InvalidPhoneNumberFailure when exception is thrown',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.sendOtp(any()),
        ).thenThrow(InvalidPhoneNumberException());

        // act
        final result = await repository.sendOtp(testPhoneNumber);

        // assert
        expect(result, Left(InvalidPhoneNumberFailure()));
        verify(() => mockRemoteDataSource.sendOtp(testPhoneNumber)).called(1);
      },
    );

    test(
      'should return NetworkFailure when NetworkException is thrown',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.sendOtp(any()),
        ).thenThrow(NetworkException());

        // act
        final result = await repository.sendOtp(testPhoneNumber);

        // assert
        expect(result, Left(NetworkFailure()));
        verify(() => mockRemoteDataSource.sendOtp(testPhoneNumber)).called(1);
      },
    );
  });

  group('verifyOtp', () {
    const testVerificationId = 'test_verification_id';
    const testOtp = '123456';
    const testUserModel = UserModel(
      uid: 'test_uid',
      phoneNumber: '+1234567890',
    );

    test('should return User when call to data source is successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.verifyOtp(
          verificationId: any(named: 'verificationId'),
          otp: any(named: 'otp'),
        ),
      ).thenAnswer((_) async => testUserModel);

      // act
      final result = await repository.verifyOtp(
        verificationId: testVerificationId,
        otp: testOtp,
      );

      // assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should return Right'), (r) {
        expect(r, isA<User>());
        expect(r.uid, testUserModel.uid);
        expect(r.phoneNumber, testUserModel.phoneNumber);
      });
      verify(
        () => mockRemoteDataSource.verifyOtp(
          verificationId: testVerificationId,
          otp: testOtp,
        ),
      ).called(1);
    });

    test('should return InvalidOtpFailure when exception is thrown', () async {
      // arrange
      when(
        () => mockRemoteDataSource.verifyOtp(
          verificationId: any(named: 'verificationId'),
          otp: any(named: 'otp'),
        ),
      ).thenThrow(InvalidOtpException());

      // act
      final result = await repository.verifyOtp(
        verificationId: testVerificationId,
        otp: testOtp,
      );

      // assert
      expect(result, Left(InvalidOtpFailure()));
    });
  });

  group('logout', () {
    test('should complete successfully when data source succeeds', () async {
      // arrange
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Right(null));
      verify(() => mockRemoteDataSource.logout()).called(1);
    });

    test('should return UnknownAuthFailure when exception is thrown', () async {
      // arrange
      when(
        () => mockRemoteDataSource.logout(),
      ).thenThrow(UnknownAuthException('Logout failed'));

      // act
      final result = await repository.logout();

      // assert
      expect(result.isLeft(), true);
      result.fold((l) {
        expect(l, isA<UnknownAuthFailure>());
        expect((l as UnknownAuthFailure).message, 'Logout failed');
      }, (r) => fail('Should return Left'));
    });
  });

  group('getCurrentUser', () {
    const testUserModel = UserModel(
      uid: 'test_uid',
      phoneNumber: '+1234567890',
    );

    test('should return User when user is logged in', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => testUserModel);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should return Right'), (r) {
        expect(r, isA<User>());
        expect(r?.uid, testUserModel.uid);
      });
    });

    test('should return null when no user is logged in', () async {
      // arrange
      when(
        () => mockRemoteDataSource.getCurrentUser(),
      ).thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Right(null));
    });
  });
}

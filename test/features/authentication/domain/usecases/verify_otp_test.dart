import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/usecases/verify_otp.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyOtp usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = VerifyOtp(mockRepository);
  });

  const testVerificationId = 'test_verification_id';
  const testOtp = '123456';
  const testUser = User(
    uid: 'test_uid',
    phoneNumber: '+1234567890',
  );

  test('should forward call to repository with correct parameters', () async {
    // arrange
    when(() => mockRepository.verifyOtp(
          verificationId: any(named: 'verificationId'),
          otp: any(named: 'otp'),
        )).thenAnswer((_) async => const Right(testUser));

    // act
    final result = await usecase(VerifyOtpParams(
      verificationId: testVerificationId,
      otp: testOtp,
    ));

    // assert
    expect(result, const Right(testUser));
    verify(() => mockRepository.verifyOtp(
          verificationId: testVerificationId,
          otp: testOtp,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

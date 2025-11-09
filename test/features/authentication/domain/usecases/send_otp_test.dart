import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/usecases/send_otp.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SendOtp usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SendOtp(mockRepository);
  });

  const testPhoneNumber = '+1234567890';
  const testVerificationId = 'test_verification_id';

  test('should forward call to repository', () async {
    // arrange
    when(() => mockRepository.sendOtp(any()))
        .thenAnswer((_) async => const Right(testVerificationId));

    // act
    final result = await usecase(SendOtpParams(testPhoneNumber));

    // assert
    expect(result, const Right(testVerificationId));
    verify(() => mockRepository.sendOtp(testPhoneNumber)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

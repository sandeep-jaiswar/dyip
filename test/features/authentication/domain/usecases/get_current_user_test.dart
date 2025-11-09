import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/usecases/get_current_user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUser(mockRepository);
  });

  const testUser = User(
    uid: 'test_uid',
    phoneNumber: '+1234567890',
    displayName: 'Test User',
  );

  group('GetCurrentUser', () {
    test('should return current user from repository', () async {
      // arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(testUser));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(testUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no user is authenticated', () async {
      // arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      final failure = NetworkFailure();
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Left(failure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}

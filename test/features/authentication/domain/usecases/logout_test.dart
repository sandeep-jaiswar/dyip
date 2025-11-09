import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/usecases/logout.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late Logout usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = Logout(mockRepository);
  });

  test('should forward call to repository', () async {
    // arrange
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Right(null));
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

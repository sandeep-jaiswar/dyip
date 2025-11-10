import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/data/models/user_model.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';

class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late MockFirebaseUser mockFirebaseUser;

  setUp(() {
    mockFirebaseUser = MockFirebaseUser();
  });

  group('UserModel', () {
    const testUid = 'test_uid_123';
    const testPhoneNumber = '+1234567890';
    const testDisplayName = 'Test User';

    test('should be a subclass of User entity', () {
      // arrange
      const userModel = UserModel(
        uid: testUid,
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );

      // assert
      expect(userModel, isA<User>());
    });

    test('fromFirebaseUser should create UserModel from Firebase User', () {
      // arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(() => mockFirebaseUser.phoneNumber).thenReturn(testPhoneNumber);
      when(() => mockFirebaseUser.displayName).thenReturn(testDisplayName);

      // act
      final result = UserModel.fromFirebaseUser(mockFirebaseUser);

      // assert
      expect(result.uid, testUid);
      expect(result.phoneNumber, testPhoneNumber);
      expect(result.displayName, testDisplayName);
    });

    test('fromFirebaseUser should handle null phone number and display name',
        () {
      // arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(() => mockFirebaseUser.phoneNumber).thenReturn(null);
      when(() => mockFirebaseUser.displayName).thenReturn(null);

      // act
      final result = UserModel.fromFirebaseUser(mockFirebaseUser);

      // assert
      expect(result.uid, testUid);
      expect(result.phoneNumber, isNull);
      expect(result.displayName, isNull);
    });

    test('toEntity should convert UserModel to User entity', () {
      // arrange
      const userModel = UserModel(
        uid: testUid,
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );

      // act
      final result = userModel.toEntity();

      // assert
      expect(result, isA<User>());
      expect(result.uid, testUid);
      expect(result.phoneNumber, testPhoneNumber);
      expect(result.displayName, testDisplayName);
    });

    test('should support value equality', () {
      // arrange
      const userModel1 = UserModel(
        uid: testUid,
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );
      const userModel2 = UserModel(
        uid: testUid,
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );

      // assert
      expect(userModel1, equals(userModel2));
    });

    test('should have different values for different users', () {
      // arrange
      const userModel1 = UserModel(
        uid: testUid,
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );
      const userModel2 = UserModel(
        uid: 'different_uid',
        phoneNumber: testPhoneNumber,
        displayName: testDisplayName,
      );

      // assert
      expect(userModel1, isNot(equals(userModel2)));
    });
  });
}

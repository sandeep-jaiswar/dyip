import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mocktail/mocktail.dart';
import 'package:dyip/core/error/exceptions.dart';
import 'package:dyip/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:dyip/features/authentication/data/models/user_model.dart';

class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

class MockUser extends Mock implements firebase_auth.User {}

class MockPhoneAuthCredential extends Mock
    implements firebase_auth.PhoneAuthCredential {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    dataSource = AuthRemoteDataSourceImpl(firebaseAuth: mockFirebaseAuth);
  });

  group('AuthRemoteDataSource', () {
    group('sendOtp', () {
      const testPhoneNumber = '+1234567890';
      const testVerificationId = 'test_verification_id_123';

      test('should return verification ID when code is sent successfully',
          () async {
        // arrange
        when(() => mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              verificationCompleted: any(named: 'verificationCompleted'),
              verificationFailed: any(named: 'verificationFailed'),
              codeSent: any(named: 'codeSent'),
              codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
              timeout: any(named: 'timeout'),
            )).thenAnswer((invocation) async {
          // Simulate codeSent callback
          final codeSent = invocation.namedArguments[const Symbol('codeSent')]
              as void Function(String, int?);
          codeSent(testVerificationId, null);
        });

        // act
        final result = await dataSource.sendOtp(testPhoneNumber);

        // assert
        expect(result, testVerificationId);
        verify(() => mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: testPhoneNumber,
              verificationCompleted: any(named: 'verificationCompleted'),
              verificationFailed: any(named: 'verificationFailed'),
              codeSent: any(named: 'codeSent'),
              codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
              timeout: any(named: 'timeout'),
            )).called(1);
      });

      test('should throw exception when verification fails', () async {
        // arrange
        when(() => mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              verificationCompleted: any(named: 'verificationCompleted'),
              verificationFailed: any(named: 'verificationFailed'),
              codeSent: any(named: 'codeSent'),
              codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
              timeout: any(named: 'timeout'),
            )).thenAnswer((invocation) async {
          // Simulate verificationFailed callback
          final verificationFailed =
              invocation.namedArguments[const Symbol('verificationFailed')]
                  as void Function(firebase_auth.FirebaseAuthException);
          verificationFailed(firebase_auth.FirebaseAuthException(
              code: 'invalid-phone-number'));
        });

        // act & assert
        expect(
          () => dataSource.sendOtp(testPhoneNumber),
          throwsA(isA<InvalidPhoneNumberException>()),
        );
      });

      test('should return verification ID on auto-retrieval timeout', () async {
        // arrange
        when(() => mockFirebaseAuth.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              verificationCompleted: any(named: 'verificationCompleted'),
              verificationFailed: any(named: 'verificationFailed'),
              codeSent: any(named: 'codeSent'),
              codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
              timeout: any(named: 'timeout'),
            )).thenAnswer((invocation) async {
          // Simulate codeAutoRetrievalTimeout callback (when codeSent wasn't called)
          final codeAutoRetrievalTimeout = invocation
                  .namedArguments[const Symbol('codeAutoRetrievalTimeout')]
              as void Function(String);
          codeAutoRetrievalTimeout(testVerificationId);
        });

        // act
        final result = await dataSource.sendOtp(testPhoneNumber);

        // assert
        expect(result, testVerificationId);
      });
    });

    group('verifyOtp', () {
      const testVerificationId = 'test_verification_id';
      const testOtp = '123456';
      const testUid = 'test_uid';
      const testPhoneNumber = '+1234567890';

      test('should return UserModel when OTP verification succeeds', () async {
        // arrange
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.phoneNumber).thenReturn(testPhoneNumber);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockUserCredential);

        // act
        final result = await dataSource.verifyOtp(
          verificationId: testVerificationId,
          otp: testOtp,
        );

        // assert
        expect(result, isA<UserModel>());
        expect(result.uid, testUid);
        expect(result.phoneNumber, testPhoneNumber);
        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      });

      test('should throw UserNotFoundException when user is null', () async {
        // arrange
        when(() => mockUserCredential.user).thenReturn(null);
        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockUserCredential);

        // act & assert
        expect(
          () => dataSource.verifyOtp(
            verificationId: testVerificationId,
            otp: testOtp,
          ),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('should throw InvalidOtpException on invalid verification code',
          () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'invalid-verification-code',
          ),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(
            verificationId: testVerificationId,
            otp: testOtp,
          ),
          throwsA(isA<InvalidOtpException>()),
        );
      });

      test('should throw InvalidOtpException on invalid verification id',
          () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'invalid-verification-id'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(
            verificationId: testVerificationId,
            otp: testOtp,
          ),
          throwsA(isA<InvalidOtpException>()),
        );
      });
    });

    group('logout', () {
      test('should call signOut on FirebaseAuth', () async {
        // arrange
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // act
        await dataSource.logout();

        // assert
        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('should throw UnknownAuthException on FirebaseAuthException',
          () async {
        // arrange
        when(() => mockFirebaseAuth.signOut()).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'unknown'),
        );

        // act & assert
        expect(() => dataSource.logout(), throwsA(isA<UnknownAuthException>()));
      });
    });

    group('getCurrentUser', () {
      const testUid = 'test_uid';
      const testPhoneNumber = '+1234567890';

      test('should return UserModel when user is logged in', () async {
        // arrange
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.phoneNumber).thenReturn(testPhoneNumber);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, isA<UserModel>());
        expect(result?.uid, testUid);
        expect(result?.phoneNumber, testPhoneNumber);
      });

      test('should return null when no user is logged in', () async {
        // arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // act
        final result = await dataSource.getCurrentUser();

        // assert
        expect(result, isNull);
      });

      test('should throw UnknownAuthException on error', () async {
        // arrange
        when(() => mockFirebaseAuth.currentUser).thenThrow(Exception('Error'));

        // act & assert
        expect(() => dataSource.getCurrentUser(),
            throwsA(isA<UnknownAuthException>()));
      });
    });

    group('authStateChanges', () {
      test('should return stream of UserModel', () async {
        // arrange
        const testUid = 'test_uid';
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.phoneNumber).thenReturn('+1234567890');
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(mockUser));

        // act
        final stream = dataSource.authStateChanges;

        // assert
        expect(stream, emits(isA<UserModel>()));
      });

      test('should return stream of null when user logs out', () async {
        // arrange
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => Stream.value(null));

        // act
        final stream = dataSource.authStateChanges;

        // assert
        expect(stream, emits(isNull));
      });
    });

    group('exception mapping', () {
      test('should map invalid-phone-number to InvalidPhoneNumberException',
          () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'invalid-phone-number'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(isA<InvalidPhoneNumberException>()),
        );
      });

      test('should map user-not-found to UserNotFoundException', () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'user-not-found'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('should map session-expired to SessionExpiredException', () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'session-expired'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(isA<SessionExpiredException>()),
        );
      });

      test('should map too-many-requests to TooManyRequestsException',
          () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'too-many-requests'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(isA<TooManyRequestsException>()),
        );
      });

      test('should map network-request-failed to NetworkException', () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(code: 'network-request-failed'),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should map unknown error to UnknownAuthException', () async {
        // arrange
        when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(
          firebase_auth.FirebaseAuthException(
            code: 'unknown-error',
            message: 'Test error',
          ),
        );

        // act & assert
        expect(
          () => dataSource.verifyOtp(verificationId: 'test', otp: '123456'),
          throwsA(
            predicate(
                (e) => e is UnknownAuthException && e.message == 'Test error'),
          ),
        );
      });
    });
  });
}

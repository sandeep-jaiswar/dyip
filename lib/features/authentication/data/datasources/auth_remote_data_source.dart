import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dyip/core/error/exceptions.dart';
import 'package:dyip/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Send OTP to the given phone number
  /// Returns verification ID for OTP verification
  Future<String> sendOtp(String phoneNumber);

  /// Verify the OTP with the verification ID
  /// Returns the authenticated user
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
  });

  /// Logout the current user
  Future<void> logout();

  /// Get the current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<String> sendOtp(String phoneNumber) async {
    try {
      String? verificationId;
      Exception? verificationException;

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) {
          // Auto-verification completed
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          verificationException = _mapFirebaseException(e);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait a bit for the callback to be invoked
      await Future.delayed(const Duration(seconds: 2));

      if (verificationException != null) {
        throw verificationException!;
      }

      if (verificationId == null) {
        throw UnknownAuthException('Failed to send OTP');
      }

      return verificationId!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw UserNotFoundException();
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  Exception _mapFirebaseException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return InvalidPhoneNumberException();
      case 'invalid-verification-code':
        return InvalidOtpException();
      case 'invalid-verification-id':
        return InvalidOtpException();
      case 'user-not-found':
        return UserNotFoundException();
      case 'session-expired':
        return SessionExpiredException();
      case 'too-many-requests':
        return TooManyRequestsException();
      case 'network-request-failed':
        return NetworkException();
      default:
        return UnknownAuthException(e.message ?? 'Unknown error occurred');
    }
  }
}

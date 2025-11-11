import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dyip/core/error/exceptions.dart';
import 'package:dyip/features/authentication/data/models/user_model.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';

abstract class AuthRemoteDataSource {
  /// Send OTP to the given phone number
  /// Returns either CodeSent(verificationId) when codeSent, or Initiated when verification started (non-blocking).
  Future<SendOtpResult> sendOtp(String phoneNumber);

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
  Future<SendOtpResult> sendOtp(String phoneNumber) async {
    try {
      final completer = Completer<SendOtpResult>();

      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification completed - sign in automatically
          try {
            // sign in but do not return AutoVerified; rely on authStateChanges
            await firebaseAuth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(const Initiated());
            }
          } on firebase_auth.FirebaseAuthException catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(_mapFirebaseException(e));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(UnknownAuthException(e.toString()));
            }
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          final mapped = _mapFirebaseException(e);
          if (!completer.isCompleted) {
            completer.completeError(mapped);
          }
        },
        codeSent: (String verId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(CodeSent(verId));
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          // Timeout - but we should have gotten codeSent already
          if (!completer.isCompleted) {
            completer.complete(CodeSent(verId));
          }
        },
        timeout: const Duration(seconds: 60),
      );

      // if verifyPhoneNumber returns immediately without calling callbacks,
      // ensure we at least return an Initiated to signal the flow started.
      return completer.future.timeout(const Duration(seconds: 65),
          onTimeout: () {
        if (!completer.isCompleted) completer.complete(const Initiated());
        return const Initiated();
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is Exception) rethrow;
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

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        // Throw UserNotFoundException directly so callers/tests can catch it.
        throw UserNotFoundException();
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
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

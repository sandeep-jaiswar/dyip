import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';
import 'package:dyip/features/authentication/domain/entities/send_otp_result.dart';
import 'package:dyip/features/authentication/domain/usecases/get_current_user.dart';
import 'package:dyip/features/authentication/domain/usecases/logout.dart';
import 'package:dyip/features/authentication/domain/usecases/send_otp.dart';
import 'package:dyip/features/authentication/domain/usecases/verify_otp.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';

class MockSendOtp extends Mock implements SendOtp {}

class MockVerifyOtp extends Mock implements VerifyOtp {}

class MockLogout extends Mock implements Logout {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late AuthBloc bloc;
  late MockSendOtp mockSendOtp;
  late MockVerifyOtp mockVerifyOtp;
  late MockLogout mockLogout;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockSendOtp = MockSendOtp();
    mockVerifyOtp = MockVerifyOtp();
    mockLogout = MockLogout();
    mockGetCurrentUser = MockGetCurrentUser();

    bloc = AuthBloc(
      sendOtp: mockSendOtp,
      verifyOtp: mockVerifyOtp,
      logout: mockLogout,
      getCurrentUser: mockGetCurrentUser,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(SendOtpParams('+1234567890'));
    registerFallbackValue(
      VerifyOtpParams(verificationId: 'test_id', otp: '123456'),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CheckAuthStatusEvent', () {
    const testUser = User(uid: 'test_uid', phoneNumber: '+1234567890');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when user is logged in',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [AuthLoading(), const Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when no user is logged in',
      build: () {
        when(
          () => mockGetCurrentUser(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [AuthLoading(), Unauthenticated()],
    );
  });

  group('SendOtpEvent', () {
    const testPhoneNumber = '+1234567890';
    const testVerificationId = 'test_verification_id';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpSent] when OTP is sent successfully',
      build: () {
        when(
          () => mockSendOtp(any()),
        ).thenAnswer((_) async => Right(CodeSent(testVerificationId)));
        return bloc;
      },
      act: (bloc) => bloc.add(const SendOtpEvent(testPhoneNumber)),
      expect: () => [AuthLoading(), const OtpSent(testVerificationId)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpInitiated] when sendOtp initiates without codeSent',
      build: () {
        when(() => mockSendOtp(any())).thenAnswer((_) async => Right(const Initiated()));
        return bloc;
      },
      act: (bloc) => bloc.add(const SendOtpEvent(testPhoneNumber)),
      expect: () => [AuthLoading(), OtpInitiated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sending OTP fails',
      build: () {
        when(
          () => mockSendOtp(any()),
        ).thenAnswer((_) async => Left(InvalidPhoneNumberFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(const SendOtpEvent(testPhoneNumber)),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid phone number. Please check and try again.'),
      ],
    );
  });

  group('VerifyOtpEvent', () {
    const testVerificationId = 'test_verification_id';
    const testOtp = '123456';
    const testUser = User(uid: 'test_uid', phoneNumber: '+1234567890');

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when OTP is verified successfully',
      build: () {
        when(
          () => mockVerifyOtp(any()),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const VerifyOtpEvent(verificationId: testVerificationId, otp: testOtp),
      ),
      expect: () => [AuthLoading(), const Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when OTP verification fails',
      build: () {
        when(
          () => mockVerifyOtp(any()),
        ).thenAnswer((_) async => Left(InvalidOtpFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const VerifyOtpEvent(verificationId: testVerificationId, otp: testOtp),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError('Invalid OTP. Please check and try again.'),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when logout is successful',
      build: () {
        when(
          () => mockLogout(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogout(any())).thenAnswer(
          (_) async => Left(const UnknownAuthFailure('Logout failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [AuthLoading(), const AuthError('Logout failed')],
    );
  });
}

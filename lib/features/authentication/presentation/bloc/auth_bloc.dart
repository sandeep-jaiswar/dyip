import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dyip/core/error/failures.dart';
import 'package:dyip/core/usecases/usecase.dart';
import 'package:dyip/features/authentication/domain/usecases/get_current_user.dart';
import 'package:dyip/features/authentication/domain/usecases/logout.dart';
import 'package:dyip/features/authentication/domain/usecases/send_otp.dart';
import 'package:dyip/features/authentication/domain/usecases/verify_otp.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final Logout logout;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.logout,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold((failure) => emit(Unauthenticated()), (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendOtp(SendOtpParams(event.phoneNumber));
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (verificationId) => emit(OtpSent(verificationId)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyOtp(
      VerifyOtpParams(verificationId: event.verificationId, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logout(NoParams());
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      InvalidPhoneNumberFailure() =>
        'Invalid phone number. Please check and try again.',
      InvalidOtpFailure() => 'Invalid OTP. Please check and try again.',
      SessionExpiredFailure() => 'Session expired. Please request a new OTP.',
      TooManyRequestsFailure() => 'Too many requests. Please try again later.',
      NetworkFailure() => 'Network error. Please check your connection.',
      UserNotFoundFailure() => 'User not found.',
      UnknownAuthFailure(:final message) => message,
      _ => 'An unexpected error occurred. Please try again.',
    };
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:dyip/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:dyip/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:dyip/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dyip/features/authentication/domain/usecases/get_current_user.dart';
import 'package:dyip/features/authentication/domain/usecases/logout.dart';
import 'package:dyip/features/authentication/domain/usecases/send_otp.dart';
import 'package:dyip/features/authentication/domain/usecases/verify_otp.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';

class DependencyInjection {
  static AuthBloc provideAuthBloc() {
    // Firebase
    final firebaseAuth = FirebaseAuth.instance;

    // Data sources
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
    );

    // Repositories
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );

    // Use cases
    final sendOtp = SendOtp(authRepository);
    final verifyOtp = VerifyOtp(authRepository);
    final logout = Logout(authRepository);
    final getCurrentUser = GetCurrentUser(authRepository);

    // BLoC
    return AuthBloc(
      sendOtp: sendOtp,
      verifyOtp: verifyOtp,
      logout: logout,
      getCurrentUser: getCurrentUser,
    );
  }
}

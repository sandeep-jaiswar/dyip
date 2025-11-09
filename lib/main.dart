import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dyip/injection.dart';
import 'package:dyip/firebase_options.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';
import 'package:dyip/features/authentication/presentation/pages/phone_input_screen.dart';
import 'package:dyip/features/authentication/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (optional for tests)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - this is expected in test environment
    // Firebase will use default/empty values
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DependencyInjection.provideAuthBloc()..add(CheckAuthStatusEvent()),
      child: MaterialApp(
        title: 'Phone Auth Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is Authenticated) {
              return const HomeScreen();
            } else {
              return const PhoneInputScreen();
            }
          },
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';
import 'package:dyip/features/authentication/presentation/pages/otp_verification_screen.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    registerFallbackValue(
      const VerifyOtpEvent(verificationId: '', otp: ''),
    );
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(home: body),
    );
  }

  group('OtpVerificationScreen', () {
    const testVerificationId = 'test_verification_id';
    const testPhoneNumber = '+1234567890';

    testWidgets('should display all UI elements', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );

      // assert
      expect(find.text('Enter Verification Code'), findsOneWidget);
      expect(find.text('We sent an OTP to $testPhoneNumber'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('Request New OTP'), findsOneWidget);
    });

    testWidgets('should show loading indicator when state is AuthLoading',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthLoading()));

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should validate empty OTP', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );
      await tester.tap(find.text('Verify OTP'));
      await tester.pump();

      // assert
      expect(find.text('Please enter the OTP'), findsOneWidget);
    });

    testWidgets('should validate OTP length', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.text('Verify OTP'));
      await tester.pump();

      // assert
      expect(find.text('OTP must be 6 digits'), findsOneWidget);
    });

    testWidgets('should validate OTP contains only numbers',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '12a456');
      await tester.tap(find.text('Verify OTP'));
      await tester.pump();

      // assert
      expect(find.text('OTP must contain only numbers'), findsOneWidget);
    });

    testWidgets('should trigger VerifyOtpEvent when valid OTP is entered',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));
      when(() => mockAuthBloc.add(any())).thenReturn(null);

      // act
      await tester.pumpWidget(
        makeTestableWidget(
          const OtpVerificationScreen(
            verificationId: testVerificationId,
            phoneNumber: testPhoneNumber,
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.text('Verify OTP'));
      await tester.pump();

      // assert
      verify(() => mockAuthBloc.add(any(that: isA<VerifyOtpEvent>())))
          .called(1);
    });

    testWidgets('should navigate back when Request New OTP is tapped',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(Unauthenticated()));

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthBloc>.value(
            value: mockAuthBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OtpVerificationScreen(
                            verificationId: testVerificationId,
                            phoneNumber: testPhoneNumber,
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to OTP'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to OTP'));
      await tester.pumpAndSettle();

      // Verify we're on OTP screen
      expect(find.text('Enter Verification Code'), findsOneWidget);

      // Tap Request New OTP
      await tester.tap(find.text('Request New OTP'));
      await tester.pumpAndSettle();

      // Verify we're back
      expect(find.text('Go to OTP'), findsOneWidget);
    });
  });
}

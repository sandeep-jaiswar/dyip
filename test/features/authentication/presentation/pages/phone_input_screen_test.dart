import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';
import 'package:dyip/features/authentication/presentation/pages/phone_input_screen.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    registerFallbackValue(const SendOtpEvent('+1234567890'));
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('should display phone input screen with all elements',
      (WidgetTester tester) async {
    // arrange
    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(Unauthenticated()));

    // act
    await tester.pumpWidget(makeTestableWidget(const PhoneInputScreen()));

    // assert
    expect(find.text('Enter Your Phone Number'), findsOneWidget);
    expect(find.text('We will send you an OTP for verification'),
        findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });

  testWidgets('should show loading indicator when state is AuthLoading',
      (WidgetTester tester) async {
    // arrange
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(AuthLoading()));

    // act
    await tester.pumpWidget(makeTestableWidget(const PhoneInputScreen()));

    // assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should validate empty phone number',
      (WidgetTester tester) async {
    // arrange
    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(Unauthenticated()));

    // act
    await tester.pumpWidget(makeTestableWidget(const PhoneInputScreen()));
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    // assert
    expect(find.text('Please enter your phone number'), findsOneWidget);
  });

  testWidgets('should trigger SendOtpEvent when valid phone number is entered',
      (WidgetTester tester) async {
    // arrange
    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(Unauthenticated()));
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    // act
    await tester.pumpWidget(makeTestableWidget(const PhoneInputScreen()));
    await tester.enterText(find.byType(TextFormField), '+1234567890');
    await tester.tap(find.text('Send OTP'));
    await tester.pump();

    // assert
    verify(() => mockAuthBloc.add(any(that: isA<SendOtpEvent>()))).called(1);
  });
}

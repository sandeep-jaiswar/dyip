import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_event.dart';
import 'package:dyip/features/authentication/presentation/bloc/auth_state.dart';
import 'package:dyip/features/authentication/presentation/pages/home_screen.dart';
import 'package:dyip/features/authentication/domain/entities/user.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    registerFallbackValue(LogoutEvent());
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(home: body),
    );
  }

  group('HomeScreen', () {
    const testUser = User(
      uid: 'test_uid',
      phoneNumber: '+1234567890',
      displayName: 'Test User',
    );

    testWidgets('should display user information when authenticated',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      // assert
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Phone: ${testUser.phoneNumber}'), findsOneWidget);
      expect(find.text('User ID: ${testUser.uid}'), findsOneWidget);
      expect(find.text('You are successfully authenticated!'), findsOneWidget);
    });

    testWidgets('should display loading indicator when state is AuthLoading',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(AuthLoading()));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display logout button', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      // assert
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byTooltip('Logout'), findsOneWidget);
    });

    testWidgets('should show logout confirmation dialog when logout tapped',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // assert
      expect(find.text('Logout'), findsNWidgets(2)); // Title and button
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should cancel logout when Cancel is tapped',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // assert
      verifyNever(() => mockAuthBloc.add(any()));
      expect(find.text('Welcome!'), findsOneWidget);
    });

    testWidgets('should trigger LogoutEvent when logout confirmed',
        (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));
      when(() => mockAuthBloc.add(any())).thenReturn(null);

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle();

      // assert
      verify(() => mockAuthBloc.add(any(that: isA<LogoutEvent>()))).called(1);
    });

    testWidgets('should handle user with null phone number',
        (WidgetTester tester) async {
      // arrange
      const userWithoutPhone = User(uid: 'test_uid');
      when(() => mockAuthBloc.state)
          .thenReturn(const Authenticated(userWithoutPhone));
      when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(const Authenticated(userWithoutPhone)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      // assert
      expect(find.text('Phone: N/A'), findsOneWidget);
    });

    testWidgets('should display error message when state is AuthError',
        (WidgetTester tester) async {
      // arrange
      const testErrorMessage = 'Test error message';
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const Authenticated(testUser),
          const AuthError(testErrorMessage),
        ]),
      );

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));
      await tester.pump();

      // assert
      expect(find.text(testErrorMessage), findsOneWidget);
    });

    testWidgets('should display check icon', (WidgetTester tester) async {
      // arrange
      when(() => mockAuthBloc.state).thenReturn(const Authenticated(testUser));
      when(() => mockAuthBloc.stream)
          .thenAnswer((_) => Stream.value(const Authenticated(testUser)));

      // act
      await tester.pumpWidget(makeTestableWidget(const HomeScreen()));

      // assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}

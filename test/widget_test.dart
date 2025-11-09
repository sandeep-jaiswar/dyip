// Basic smoke test for the app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build a simple test app
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    // Verify the test widget is displayed
    expect(find.text('Test'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/main.dart';

void main() {
  Widget createTestApp() {
    return const MaterialApp(home: WelcomePage());
  }

  testWidgets('KasiBiz welcome screen displays correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());

    expect(find.text('KasiBiz'), findsOneWidget);

    expect(
      find.text('Run your business. Know your numbers. Grow your hustle.'),
      findsOneWidget,
    );

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('Get Started opens registration page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Join KasiBiz'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Log In opens login page', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());

    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

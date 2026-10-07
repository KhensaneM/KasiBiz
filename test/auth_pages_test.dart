import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/login_page.dart';
import 'package:kasibiz/pages/register_page.dart';

void main() {
  group('Login Page Tests', () {
    testWidgets('Login page displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsWidgets);
    });

    testWidgets('Login page has email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Password field hides entered password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      final fields = tester.widgetList<TextField>(find.byType(TextField));

      expect(fields.last.obscureText, isTrue);
    });
  });

  group('Registration Page Tests', () {
    testWidgets('Registration page displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Join KasiBiz'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Registration page has three input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('Registration password field hides password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

      final fields = tester.widgetList<TextField>(find.byType(TextField));

      expect(fields.last.obscureText, isTrue);
    });
  });
}

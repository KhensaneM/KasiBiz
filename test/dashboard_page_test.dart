import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/logged_in_page.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    final mockUser = MockUser(
      uid: 'test-user-123',
      email: 'khensane@example.com',
      displayName: 'Khensane',
    );

    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
  });

  Widget createDashboard() {
    return MaterialApp(home: DashboardPage(auth: mockAuth));
  }

  group('Dashboard Page Tests', () {
    testWidgets('Dashboard displays title and logged in user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDashboard());

      expect(find.text('KasiBiz Dashboard'), findsOneWidget);

      expect(find.text('Welcome, Khensane!'), findsOneWidget);

      expect(find.text('khensane@example.com'), findsOneWidget);

      expect(find.text('Here is your business overview.'), findsOneWidget);
    });

    testWidgets('Dashboard displays business summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDashboard());

      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);

      expect(find.text('R0.00'), findsNWidgets(3));
    });

    testWidgets('Dashboard displays business management options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDashboard());

      expect(find.text('Manage Business'), findsOneWidget);

      expect(find.text('Products & Services'), findsOneWidget);

      expect(find.text('Record Sale'), findsOneWidget);

      expect(find.text('Record Expense'), findsOneWidget);
    });


    testWidgets('Record Expense shows coming soon message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDashboard());

      await tester.ensureVisible(find.text('Record Expense'));

      await tester.tap(find.text('Record Expense'));

      await tester.pump();

      expect(find.text('Record Expense is coming next.'), findsOneWidget);
    });

    testWidgets('Log Out signs the user out', (WidgetTester tester) async {
      await tester.pumpWidget(createDashboard());

      expect(mockAuth.currentUser, isNotNull);

      final logoutButton = find.widgetWithText(OutlinedButton, 'Log Out');

      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNull);
    });
  });
}

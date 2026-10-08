
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/logged_in_page.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  const userId = 'test-user-123';

  setUp(() {
    final mockUser = MockUser(
      uid: userId,
      email: 'khensane@example.com',
      displayName: 'Khensane',
    );

    mockAuth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: true,
    );

    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createDashboard() {
    return MaterialApp(
      home: DashboardPage(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  group('Dashboard Page Tests', () {
    testWidgets('Dashboard displays title and logged in user', (
        WidgetTester tester,
        ) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('KasiBiz Dashboard'), findsOneWidget);
      expect(find.text('Welcome, Khensane!'), findsOneWidget);
      expect(find.text('khensane@example.com'), findsOneWidget);
      expect(
        find.text('Here is your business overview.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Dashboard displays zero business summary when there are no sales',
          (WidgetTester tester) async {
        await tester.pumpWidget(createDashboard());
        await tester.pumpAndSettle();

        expect(find.text('Sales'), findsOneWidget);
        expect(find.text('Expenses'), findsOneWidget);
        expect(find.text('Profit'), findsOneWidget);

        expect(find.text('R0.00'), findsNWidgets(3));
      },
    );

    testWidgets('Dashboard calculates sales and profit from Firestore', (
        WidgetTester tester,
        ) async {
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('sales')
          .add({
        'productId': 'kota-1',
        'productName': 'Kota',
        'type': 'Product',
        'price': 35.0,
        'quantity': 2,
        'total': 70.0,
        'createdAt': DateTime.now(),
      });

      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);

      // Sales = R70.00 and Profit = R70.00.
      expect(find.text('R70.00'), findsNWidgets(2));

      // No expenses have been recorded.
      expect(find.text('R0.00'), findsOneWidget);
    });

    testWidgets('Dashboard adds multiple sales together', (
        WidgetTester tester,
        ) async {
      final sales = fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('sales');

      await sales.add({
        'productName': 'Kota',
        'total': 70.0,
      });

      await sales.add({
        'productName': 'Haircut',
        'total': 80.0,
      });

      await sales.add({
        'productName': 'Vetkoek',
        'total': 24.0,
      });

      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      // Total sales = R174.00.
      // Profit is also R174.00 because expenses are zero.
      expect(find.text('R174.00'), findsNWidgets(2));
      expect(find.text('R0.00'), findsOneWidget);
    });

    testWidgets('Dashboard calculates expenses and profit from Firestore', (
        WidgetTester tester,
        ) async {
      final sales = fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('sales');

      final expenses = fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('expenses');

      await sales.add({
        'productName': 'Kota',
        'total': 350.0,
      });

      await sales.add({
        'productName': 'Haircut',
        'total': 150.0,
      });

      await expenses.add({
        'name': 'Electricity',
        'category': 'Electricity',
        'amount': 100.0,
      });

      await expenses.add({
        'name': 'Transport',
        'category': 'Transport',
        'amount': 50.0,
      });

      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      // Sales = R500.00
      // Expenses = R150.00
      // Profit = R350.00
      expect(find.text('R500.00'), findsOneWidget);
      expect(find.text('R150.00'), findsOneWidget);
      expect(find.text('R350.00'), findsOneWidget);
    });

    testWidgets('Dashboard displays business management options', (
        WidgetTester tester,
        ) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(find.text('Manage Business'), findsOneWidget);
      expect(find.text('Products & Services'), findsOneWidget);
      expect(find.text('Record Sale'), findsOneWidget);
      expect(find.text('Record Expense'), findsOneWidget);
    });

    testWidgets('Record Expense opens the expense form', (
        WidgetTester tester,
        ) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      final recordExpense = find.text('Record Expense');

      await tester.ensureVisible(recordExpense);
      await tester.tap(recordExpense);
      await tester.pumpAndSettle();

      expect(find.text('Add Business Expense'), findsOneWidget);
      expect(find.text('Expense Name'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Amount (R)'), findsOneWidget);
      expect(find.text('Save Expense'), findsOneWidget);
    });

    testWidgets('Log Out signs the user out', (
        WidgetTester tester,
        ) async {
      await tester.pumpWidget(createDashboard());
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNotNull);

      final logoutButton = find.widgetWithText(
        OutlinedButton,
        'Log Out',
      );

      await tester.ensureVisible(logoutButton);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(mockAuth.currentUser, isNull);
    });

    testWidgets('Logged out user sees login message', (
        WidgetTester tester,
        ) async {
      final signedOutAuth = MockFirebaseAuth(
        signedIn: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(
            auth: signedOutAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Please log in to view your dashboard.'),
        findsOneWidget,
      );
    });
  });
}


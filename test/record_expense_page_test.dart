import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/record_expense_page.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  const userId = 'test-user-123';

  setUp(() {
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: userId, email: 'test@example.com'),
      signedIn: true,
    );

    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createExpensePage({MockFirebaseAuth? auth}) {
    return MaterialApp(
      home: RecordExpensePage(auth: auth ?? mockAuth, firestore: fakeFirestore),
    );
  }

  testWidgets('Displays the expense form', (tester) async {
    await tester.pumpWidget(createExpensePage());

    expect(find.text('Add Business Expense'), findsOneWidget);
    expect(find.text('Expense Name'), findsOneWidget);
    expect(find.text('Amount (R)'), findsOneWidget);
    expect(find.text('Save Expense'), findsOneWidget);
  });

  testWidgets('Saves a valid expense to Firestore', (tester) async {
    await tester.pumpWidget(createExpensePage());

    await tester.enterText(
      find.widgetWithText(TextField, 'Expense Name'),
      'Electricity',
    );

    await tester.enterText(find.widgetWithText(TextField, 'Amount (R)'), '150');

    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    final expenses = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    expect(expenses.docs.length, 1);
    expect(expenses.docs.first.data()['name'], 'Electricity');
    expect(expenses.docs.first.data()['amount'], 150.0);
    expect(expenses.docs.first.data()['category'], 'Stock');
  });

  testWidgets('Rejects an empty expense name', (tester) async {
    await tester.pumpWidget(createExpensePage());

    await tester.enterText(find.widgetWithText(TextField, 'Amount (R)'), '150');

    await tester.tap(find.text('Save Expense'));
    await tester.pump();

    expect(find.text('Enter a valid expense name and amount.'), findsOneWidget);

    final expenses = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    expect(expenses.docs, isEmpty);
  });

  testWidgets('Rejects a negative amount', (tester) async {
    await tester.pumpWidget(createExpensePage());

    await tester.enterText(
      find.widgetWithText(TextField, 'Expense Name'),
      'Transport',
    );

    await tester.enterText(find.widgetWithText(TextField, 'Amount (R)'), '-50');

    await tester.tap(find.text('Save Expense'));
    await tester.pump();

    expect(find.text('Enter a valid expense name and amount.'), findsOneWidget);

    final expenses = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    expect(expenses.docs, isEmpty);
  });

  testWidgets('Rejects saving when user is logged out', (tester) async {
    final signedOutAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(createExpensePage(auth: signedOutAuth));

    await tester.enterText(
      find.widgetWithText(TextField, 'Expense Name'),
      'Rent',
    );

    await tester.enterText(find.widgetWithText(TextField, 'Amount (R)'), '500');

    await tester.tap(find.text('Save Expense'));
    await tester.pump();

    expect(find.text('Please log in first.'), findsOneWidget);

    final expenses = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();

    expect(expenses.docs, isEmpty);
  });
}

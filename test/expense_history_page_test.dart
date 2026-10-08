import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/expense_history_page.dart';

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

  Widget createExpenseHistoryPage({MockFirebaseAuth? auth}) {
    return MaterialApp(
      home: ExpenseHistoryPage(
        auth: auth ?? mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  Future<void> addExpense({
    required String name,
    required String category,
    required double amount,
  }) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .add({
          'name': name,
          'category': category,
          'amount': amount,
          'createdAt': DateTime(2026, 10, 8),
        });
  }

  testWidgets('Displays Expense History page', (tester) async {
    await tester.pumpWidget(createExpenseHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Expense History'), findsOneWidget);
    expect(find.text('No expenses recorded yet'), findsOneWidget);
  });

  testWidgets('Displays recorded expenses', (tester) async {
    await addExpense(name: 'Electricity', category: 'Electricity', amount: 150);

    await tester.pumpWidget(createExpenseHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Electricity'), findsWidgets);
    expect(find.text('R150.00'), findsNWidgets(2));
  });

  testWidgets('Calculates total expenses correctly', (tester) async {
    await addExpense(name: 'Electricity', category: 'Electricity', amount: 150);

    await addExpense(name: 'Rent', category: 'Rent', amount: 500);

    await tester.pumpWidget(createExpenseHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('R650.00'), findsOneWidget);
  });

  testWidgets('Displays empty state when no expenses exist', (tester) async {
    await tester.pumpWidget(createExpenseHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('No expenses recorded yet'), findsOneWidget);
    expect(
      find.text('Your recorded expenses will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('Rejects unauthenticated access', (tester) async {
    final signedOutAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(createExpenseHistoryPage(auth: signedOutAuth));

    expect(find.text('Please log in to view expense history.'), findsOneWidget);
  });
}

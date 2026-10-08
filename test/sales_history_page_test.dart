import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/sales_history_page.dart';

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

  Widget createSalesHistoryPage({MockFirebaseAuth? auth}) {
    return MaterialApp(
      home: SalesHistoryPage(auth: auth ?? mockAuth, firestore: fakeFirestore),
    );
  }

  Future<void> addSale({
    required String name,
    required double total,
    int quantity = 1,
  }) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('sales')
        .add({
          'productName': name,
          'type': 'Product',
          'price': total / quantity,
          'quantity': quantity,
          'total': total,
          'createdAt': DateTime(2026, 10, 8),
        });
  }

  testWidgets('Displays Sales History page', (tester) async {
    await tester.pumpWidget(createSalesHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Sales History'), findsOneWidget);
    expect(find.text('No sales recorded yet'), findsOneWidget);
  });

  testWidgets('Displays recorded sales', (tester) async {
    await addSale(name: 'Kota', total: 70);

    await tester.pumpWidget(createSalesHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Kota'), findsOneWidget);
    expect(find.text('R70.00'), findsNWidgets(2));
    expect(find.textContaining('Quantity: 1'), findsOneWidget);
  });

  testWidgets('Calculates total sales correctly', (tester) async {
    await addSale(name: 'Kota', total: 70);
    await addSale(name: 'Haircut', total: 80);

    await tester.pumpWidget(createSalesHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('Total Sales'), findsOneWidget);
    expect(find.text('R150.00'), findsOneWidget);
  });

  testWidgets('Displays empty state when no sales exist', (tester) async {
    await tester.pumpWidget(createSalesHistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('No sales recorded yet'), findsOneWidget);
    expect(find.text('Your recorded sales will appear here.'), findsOneWidget);
  });

  testWidgets('Rejects unauthenticated access', (tester) async {
    final signedOutAuth = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(createSalesHistoryPage(auth: signedOutAuth));

    expect(find.text('Please log in to view sales history.'), findsOneWidget);
  });
}

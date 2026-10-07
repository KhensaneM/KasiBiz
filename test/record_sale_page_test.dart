import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/record_sale_page.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  const userId = 'test-user-123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();

    final mockUser = MockUser(
      uid: userId,
      email: 'khensane@example.com',
      displayName: 'Khensane',
    );

    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
  });

  Widget createSalePage() {
    return MaterialApp(
      home: RecordSalePage(auth: mockAuth, firestore: fakeFirestore),
    );
  }

  Future<void> addTestProduct({
    String name = 'Kota',
    double price = 35.0,
    String type = 'Product',
  }) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('products')
        .add({
          'name': name,
          'price': price,
          'type': type,
          'createdAt': DateTime.now(),
        });
  }

  group('Record Sale Page Tests', () {
    testWidgets('shows empty state when there are no products', (tester) async {
      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      expect(find.text('Record Sale'), findsOneWidget);

      expect(find.text('No products or services yet'), findsOneWidget);

      expect(
        find.text('Add a product or service before recording a sale.'),
        findsOneWidget,
      );
    });

    testWidgets('displays available product', (tester) async {
      await addTestProduct();

      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      expect(find.text('Kota'), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
      expect(find.text('R35.00'), findsOneWidget);
    });

    testWidgets('tapping product opens sale dialog', (tester) async {
      await addTestProduct();

      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kota'));
      await tester.pumpAndSettle();

      expect(find.text('Record Sale - Kota'), findsOneWidget);

      expect(find.text('Price: R35.00'), findsOneWidget);

      expect(find.text('Sale Total'), findsOneWidget);

      expect(find.text('R35.00'), findsWidgets);

      expect(find.text('Quantity'), findsOneWidget);
    });

    testWidgets('quantity updates sale total', (tester) async {
      await addTestProduct();

      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kota'));
      await tester.pumpAndSettle();

      final quantityField = find.byType(TextField);

      expect(quantityField, findsOneWidget);

      await tester.enterText(quantityField, '2');

      await tester.pump();

      expect(find.text('R70.00'), findsOneWidget);
    });

    testWidgets('records Kota sale with quantity 2 and total R70', (
      tester,
    ) async {
      await addTestProduct();

      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kota'));
      await tester.pumpAndSettle();

      final quantityField = find.byType(TextField);

      await tester.enterText(quantityField, '2');

      await tester.pump();

      expect(find.text('R70.00'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Record Sale'));

      await tester.pumpAndSettle();

      final salesSnapshot = await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('sales')
          .get();

      expect(salesSnapshot.docs.length, 1);

      final sale = salesSnapshot.docs.first.data();

      expect(sale['productName'], 'Kota');
      expect(sale['type'], 'Product');
      expect(sale['price'], 35.0);
      expect(sale['quantity'], 2);
      expect(sale['total'], 70.0);

      expect(find.text('Sale recorded: 2 x Kota = R70.00'), findsOneWidget);
    });

    testWidgets('invalid quantity cannot be recorded', (tester) async {
      await addTestProduct();

      await tester.pumpWidget(createSalePage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kota'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0');

      await tester.pump();

      expect(
        find.text('Please enter a quantity greater than 0.'),
        findsOneWidget,
      );

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Record Sale'),
      );

      expect(button.onPressed, isNull);
    });

    testWidgets('logged out user sees login message', (tester) async {
      final signedOutAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        MaterialApp(
          home: RecordSalePage(auth: signedOutAuth, firestore: fakeFirestore),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Please log in to record sales.'), findsOneWidget);
    });
  });
}

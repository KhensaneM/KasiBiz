import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/pages/products_page.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();

    mockUser = MockUser(
      uid: 'test-user-123',
      email: 'khensane@example.com',
      displayName: 'Khensane',
    );

    mockAuth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: true,
    );
  });

  Widget createProductsPage() {
    return MaterialApp(
      home: ProductsPage(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  group('Products Page Tests', () {
    testWidgets(
      'Products page displays empty state',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductsPage());
        await tester.pumpAndSettle();

        expect(
          find.text('Products & Services'),
          findsOneWidget,
        );

        expect(
          find.text('No products or services yet'),
          findsOneWidget,
        );

        expect(
          find.text('Add Product or Service'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Add button opens product dialog',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductsPage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(
          find.text('Add Product or Service'),
          findsWidgets,
        );

        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Price'), findsOneWidget);
        expect(find.text('Type'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'Product can be added to Firestore',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductsPage());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        final textFields = find.byType(TextField);

        expect(textFields, findsNWidgets(2));

        await tester.enterText(
          textFields.at(0),
          'Kota',
        );

        await tester.enterText(
          textFields.at(1),
          '35',
        );

        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        expect(find.text('Kota'), findsOneWidget);
        expect(find.text('Product'), findsOneWidget);
        expect(find.text('R35.00'), findsOneWidget);

        final snapshot = await fakeFirestore
            .collection('users')
            .doc('test-user-123')
            .collection('products')
            .get();

        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'Kota');
        expect(snapshot.docs.first.data()['price'], 35.0);
        expect(snapshot.docs.first.data()['type'], 'Product');
      },
    );

    testWidgets(
      'Saved product is displayed',
          (WidgetTester tester) async {
        await fakeFirestore
            .collection('users')
            .doc('test-user-123')
            .collection('products')
            .add({
          'name': 'Vetkoek',
          'price': 12.50,
          'type': 'Product',
          'createdAt': DateTime.now(),
        });

        await tester.pumpWidget(createProductsPage());
        await tester.pumpAndSettle();

        expect(find.text('Vetkoek'), findsOneWidget);
        expect(find.text('Product'), findsOneWidget);
        expect(find.text('R12.50'), findsOneWidget);
      },
    );

    testWidgets(
      'Product can be deleted',
          (WidgetTester tester) async {
        await fakeFirestore
            .collection('users')
            .doc('test-user-123')
            .collection('products')
            .add({
          'name': 'Kota',
          'price': 35.0,
          'type': 'Product',
          'createdAt': DateTime.now(),
        });

        await tester.pumpWidget(createProductsPage());
        await tester.pumpAndSettle();

        expect(find.text('Kota'), findsOneWidget);

        await tester.tap(
          find.byTooltip('Delete'),
        );

        await tester.pumpAndSettle();

        expect(find.text('Kota'), findsNothing);

        final snapshot = await fakeFirestore
            .collection('users')
            .doc('test-user-123')
            .collection('products')
            .get();

        expect(snapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'Logged out user sees login message',
          (WidgetTester tester) async {
        final signedOutAuth = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ProductsPage(
              auth: signedOutAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Please log in to manage products.'),
          findsOneWidget,
        );
      },
    );
  });
}
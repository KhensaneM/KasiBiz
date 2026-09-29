import 'package:flutter_test/flutter_test.dart';
import 'package:kasibiz/main.dart';

void main() {
  testWidgets(
    'KasiBiz welcome screen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const KasiBizApp());

      expect(find.text('KasiBiz'), findsOneWidget);

      expect(
        find.text(
          'Run your business. Know your numbers. Grow your hustle.',
        ),
        findsOneWidget,
      );

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    },
  );
}
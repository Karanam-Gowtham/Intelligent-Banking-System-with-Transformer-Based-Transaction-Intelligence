import 'package:flutter_test/flutter_test.dart';

import 'package:bank_ui/main.dart';

void main() {
  testWidgets('risk alerts screen loads provider data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Risk Alerts'), findsOneWidget);
    expect(find.text('Flagged'), findsOneWidget);
    expect(find.text('Blacklist'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Coinbase'), findsOneWidget);
    expect(find.text('Kraken'), findsOneWidget);
  });
}

import 'package:flutter/widgets.dart';
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
    expect(find.text('Priority queue'), findsOneWidget);
    expect(find.text('Details'), findsWidgets);
  });

  testWidgets('alert details sheet opens from the list', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Recommended action'), findsOneWidget);
    expect(find.text('Transaction value'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend_logistic/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WezuLogisticsApp(),
      ),
    );

    // Verify the splash screen appears
    expect(find.text('WEZU'), findsOneWidget);
    expect(find.text('Battery Logistics'), findsOneWidget);
  });
}

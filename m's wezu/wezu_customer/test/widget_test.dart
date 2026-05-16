import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wezu_customer_app/core/theme/theme_provider.dart';

void main() {
  testWidgets('Theme provider initializes with shared preferences',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeModeProvider);
              return Text(mode.name);
            },
          ),
        ),
      ),
    );

    expect(find.text('system'), findsOneWidget);
  });
}

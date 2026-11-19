import 'package:bookhub2/core/demo/demo_preview_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('demo opens without Firebase and supports local search', (
    tester,
  ) async {
    await tester.pumpWidget(const DemoPreviewApp());
    await tester.pumpAndSettle();

    expect(find.text('BookHub'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);

    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Dune');
    await tester.pumpAndSettle();

    expect(find.text('Dune'), findsWidgets);
    expect(find.text('Atomic Habits'), findsNothing);
  });

  testWidgets('demo preferences persist locally and change app theme', (
    tester,
  ) async {
    await tester.pumpWidget(const DemoPreviewApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('settings.darkMode'), isTrue);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

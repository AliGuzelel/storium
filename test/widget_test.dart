import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:storium/main.dart';
import 'package:storium/providers/settings_manager.dart';

void main() {
  testWidgets('MyApp builds with settings provider', (WidgetTester tester) async {
    final settings = SettingsManager();
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsManager>.value(
        value: settings,
        child: MyApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

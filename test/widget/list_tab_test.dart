import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:mockito/mockito.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class MockThemeModel extends Mock implements ThemeModel {
  Color accentColor;

  MockThemeModel({this.accentColor = Colors.redAccent});
}

ListenableProvider<ThemeModel> _withThemeModel(
    MockThemeModel themeModel, Widget child) {
  return ListenableProvider<ThemeModel>.value(value: themeModel, child: child);
}

void main() {
  MockThemeModel themeModel;

  setUp(() {
    themeModel = MockThemeModel();
  });

  testWidgets('ListTab has title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _withThemeModel(themeModel, ListTab('T')),
        ),
      ),
    );

    final titleFinder = find.text('T');

    expect(titleFinder, findsOneWidget);
  });
}

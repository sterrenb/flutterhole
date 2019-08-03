import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

//  setUp(() {
//    materialApp = MockMaterialApp(child: PiholeEditForm(original: original));
//  });

  group('DefaultScaffold', () {
    testWidgets('has default title', (WidgetTester tester) async {
      materialApp =
          MockMaterialApp(scaffold: DefaultScaffold(body: Container()));
      await tester.pumpWidget(materialApp);

      expect(find.text('FlutterHole'), findsOneWidget);
    });
  });

  group('SimpleScaffold', () {
    testWidgets('has title', (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          scaffold: SimpleScaffold(title: 'mock', body: Container()));
      await tester.pumpWidget(materialApp);

      expect(find.text('mock'), findsOneWidget);
    });
  });

  group('SearchScaffold', () {
    testWidgets('has title', (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          scaffold: SearchScaffold(title: 'mock', body: Container()));
      await tester.pumpWidget(materialApp);

      expect(find.text('mock'), findsOneWidget);
    });

    testWidgets('has a TextField to type in', (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          scaffold: SearchScaffold(title: 'mock', body: Container()));
      await tester.pumpWidget(materialApp);

      expect(find.byIcon(Icons.search), findsOneWidget);

      // tap search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // expect search button to be swapped with close button
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // enter text and tap close button
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.tap(find.byIcon(Icons.close));
    });
  });

  group('TabScaffold', () {
    testWidgets('has title', (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          scaffold: TabScaffold(
        title: 'mock',
        children: <Widget>[Text('A'), Text('C'), Text('C')],
        navbarItems: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Summary'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            title: Text('Clients'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            title: Text('Domains'),
          ),
        ],
      ));
      await tester.pumpWidget(materialApp);

      expect(find.text('mock'), findsOneWidget);

      // tap a bottom navigation button
      await tester.tap(find.byIcon(Icons.computer));
    });
  });
}

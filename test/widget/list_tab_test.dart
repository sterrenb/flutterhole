import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';

import 'mock_material_app.dart';

void main() {
  testWidgets('ListTab has title', (WidgetTester tester) async {
    await tester.pumpWidget(MockMaterialApp(child: ListTab('T')));

    final titleFinder = find.text('T');

    expect(titleFinder, findsOneWidget);
  });
}

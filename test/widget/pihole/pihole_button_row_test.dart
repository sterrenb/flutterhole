import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/widget/pihole/pihole_button_row.dart';

import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(child: PiholeButtonRow());
  });

  testWidgets('has buttons', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);

    expect(find.text('Add a new Pihole'), findsOneWidget);
    expect(find.text('Reset to defaults'), findsOneWidget);
  });

  testWidgets('add button', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    await tester.tap(find.text('Add a new Pihole'));
  });

  testWidgets('shows warning dialog on reset tap', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    await tester.tap(find.text('Reset to defaults'));
    await tester.pumpAndSettle();

    expect(
        find.text('Do you want to remove all configurations?'), findsOneWidget);

    await tester.tap(find.text('Remove all'));
    await tester.pumpAndSettle();

    expect(
        find.text('Do you want to remove all configurations?'), findsNothing);
  });
}

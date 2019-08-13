import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/whitelist/whitelist_add_form.dart';
import 'package:flutterhole/widget/whitelist/whitelist_form.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUpAll(() {
    Globals.client = MockPiholeClient();
    Globals.router = MockRouter();
    Globals.tree = MockMemoryTree();
  });

  setUp(() {
    materialApp = MockMaterialApp(child: WhitelistAddForm());
  });

  testWidgets('has WhitelistForm', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    expect(find.byType(WhitelistForm), findsOneWidget);
  });
}

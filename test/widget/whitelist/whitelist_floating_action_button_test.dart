import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/whitelist/whitelist_floating_action_button.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;
  MockRouter router;

  setUp(() {
    materialApp = MockMaterialApp(child: WhitelistFloatingActionButton());
    router = MockRouter();
    Globals.router = router;
    Globals.client = MockPiholeClient();
  });

  testWidgets('returns Container for anything but success',
      (WidgetTester tester) async {
    when(materialApp.whitelistBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<Whitelist>());

    await tester.pumpWidget(materialApp);

    expect(find.byType(Container), findsOneWidget);
  });

  testWidgets('onTap', (WidgetTester tester) async {
    when(materialApp.whitelistBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Whitelist>(mockWhitelist));

    await tester.pumpWidget(materialApp);
    await tester.tap(find.byTooltip('Add to whitelist'));
  });
}

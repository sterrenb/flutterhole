import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/removable_tile.dart';
import 'package:flutterhole/widget/whitelist/whitelist_builder.dart';
import 'package:mockito/mockito.dart';

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
    materialApp = MockMaterialApp(child: WhitelistBuilder());
  });

  testWidgets('initially shows CircularProgressIndicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows CircularProgressIndicator for BlocStateEmpty<Whitelist>',
      (WidgetTester tester) async {
    when(materialApp.whitelistBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<Whitelist>());

    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows CircularProgressIndicator for BlocStateLoading<Whitelist>',
      (WidgetTester tester) async {
    when(materialApp.whitelistBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<Whitelist>());

    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows ErrorMessage for BlocStateError<Whitelist>',
      (WidgetTester tester) async {
    when(materialApp.whitelistBloc.currentState)
        .thenAnswer((_) => BlocStateError<Whitelist>(PiholeException()));

    await tester.pumpWidget(materialApp);
    expect(find.byType(ErrorMessage), findsOneWidget);
  });

  group('BlocStateSuccess<Whitelist>', () {
    setUp(() {
      when(materialApp.whitelistBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<Whitelist>(mockWhitelist));
    });

    testWidgets('has removable tiles', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      expect(
          find.byType(RemovableTile), findsNWidgets(mockWhitelist.list.length));
    });

    testWidgets('can tap to edit', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.byType(RemovableTile).first);
    });
  });
}

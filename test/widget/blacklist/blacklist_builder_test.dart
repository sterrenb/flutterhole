import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/blacklist/blacklist_builder.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/removable_tile.dart';
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
    materialApp = MockMaterialApp(child: BlacklistBuilder());
  });

  testWidgets('initially shows CircularProgressIndicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows CircularProgressIndicator for BlocStateEmpty<Blacklist>',
      (WidgetTester tester) async {
    when(materialApp.blacklistBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<Blacklist>());

    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows CircularProgressIndicator for BlocStateLoading<Blacklist>',
      (WidgetTester tester) async {
    when(materialApp.blacklistBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<Blacklist>());

    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows ErrorMessage for BlocStateError<Blacklist>',
      (WidgetTester tester) async {
    when(materialApp.blacklistBloc.currentState)
        .thenAnswer((_) => BlocStateError<Blacklist>(PiholeException()));

    await tester.pumpWidget(materialApp);
    expect(find.byType(ErrorMessage), findsOneWidget);
  });

  group('BlocStateSuccess<Blacklist>', () {
    setUp(() {
      when(materialApp.blacklistBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<Blacklist>(mockBlacklist));
    });

    testWidgets('has removable tiles', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      expect(
          find.byType(RemovableTile),
          findsNWidgets(
              mockBlacklist.exact.length + mockBlacklist.wildcard.length));
    });

    testWidgets('can tap to edit', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.byType(RemovableTile).first);
    });
  });
}

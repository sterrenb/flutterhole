import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/pihole/pihole_form.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  Pihole original;
  MockMaterialApp materialApp;

  setUpAll(() {
//    BlocSupervisor.delegate = SimpleBlocDelegate();
    Globals.client = MockPiholeClient();
    Globals.router = MockRouter();
    Globals.tree = MockMemoryTree();
  });

  setUp(() {
    original = Pihole();
    materialApp = MockMaterialApp(child: PiholeForm(original: original));
  });

  testWidgets('show form with original values', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);

    expect(find.byType(Form), findsOneWidget);
  });

  testWidgets('launches browser after tapping on example url',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialApp);
    await tester.tap(find.byTooltip('Open in browser'));
    await tester.pumpAndSettle();
  });

  group('edit fields', () {
    testWidgets('edit title', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('titleController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, title: 'hi'),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit host', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('hostController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, host: 'hi'),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit apiPath', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('apiPathController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, apiPath: 'hi'),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit port', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('portController')), '123');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, port: 123),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit auth', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('authController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, auth: 'hi'),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit useSSL', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.byKey(Key('useSSLController')));
      await tester.pumpAndSettle();
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original, useSSL: true),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit proxyHost', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('proxyHostController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original,
                proxy: Proxy.copyWith(original.proxy, host: 'hi')),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit proxyPort', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('proxyPortController')), '123');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original,
                proxy: Proxy.copyWith(original.proxy, port: 123)),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit proxyUsername', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('proxyUsernameController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original,
                proxy: Proxy.copyWith(original.proxy, username: 'hi')),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('edit proxyPassword', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byKey(Key('proxyPasswordController')), 'hi');
      verify(
        materialApp.versionsBloc.dispatch(FetchForPihole(
            Pihole.copyWith(original,
                proxy: Proxy.copyWith(original.proxy, password: 'hi')),
            cancelOldRequests: true)),
      ).called(1);
    });

    testWidgets('qr scanner tap', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
    });
  });

  group('save', () {
    testWidgets('save button tap', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.ensureVisible(find.byIcon(Icons.save));
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      verifyNever(
        materialApp.versionsBloc
            .dispatch(FetchForPihole(original, cancelOldRequests: true)),
      );
    });
  });

  group('reset', () {
    testWidgets('test button tap', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.ensureVisible(find.byIcon(Icons.delete_forever));
      await tester.tap(find.byIcon(Icons.delete_forever));
      await tester.pumpAndSettle();

      verify(
        materialApp.versionsBloc
            .dispatch(FetchForPihole(original, cancelOldRequests: true)),
      ).called(1);
    });
  });
}

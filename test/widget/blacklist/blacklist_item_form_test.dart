import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/blacklist/blacklist_item_form.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;
  GlobalKey<FormBuilderState> formKey;

  setUpAll(() {
    Globals.client = MockPiholeClient();
    Globals.router = MockRouter();
    Globals.tree = MockMemoryTree();
  });

  setUp(() {
    formKey = GlobalKey<FormBuilderState>();
  });

  group('no initial value', () {
    int submitCount;
    setUp(() {
      submitCount = 0;
      materialApp = MockMaterialApp(
          child: BlacklistItemForm(
        fbKey: formKey,
        onSubmit: () {
          submitCount++;
        },
      ));
    });

    testWidgets('has form widgets', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      expect(find.byType(FormBuilderTextField), findsOneWidget);
      expect(find.byType(FormBuilderRadio), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Remove'), findsNothing);
      expect(find.text('Blacklist entry'), findsOneWidget);
    });

    testWidgets('can submit', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.enterText(find.byType(TextField), 'test.com');
      await tester.tap(find.text('Submit'));
      expect(submitCount, 1);
    });

    testWidgets(
        'shows CircularProgressIndicator for BlocStateLoading<Blacklist>',
        (WidgetTester tester) async {
      when(materialApp.blacklistBloc.currentState)
          .thenAnswer((_) => BlocStateLoading<Blacklist>());

      await tester.pumpWidget(materialApp);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('can change BlacklistType', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.text('Wildcard'));
      await tester.pumpAndSettle();
      expect(find.text('This field cannot be empty.'), findsOneWidget);
    });

    testWidgets('can reset', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      expect(find.text('test.com'), findsNothing);
      await tester.enterText(find.byType(TextField), 'test.com');
      expect(find.text('test.com'), findsOneWidget);
      await tester.tap(find.text('Reset'));
      expect(find.text('test.com'), findsNothing);
    });
  });

  group('with initial value', () {
    BlacklistItem initialValue;
    setUp(() {
      initialValue = mockBlacklist.wildcard.first;
      materialApp = MockMaterialApp(
          child: BlacklistItemForm(
        fbKey: formKey,
        initialValue: initialValue,
        onSubmit: () {},
      ));
    });

    testWidgets('has remove widget', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      expect(find.byType(FormBuilderTextField), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('can remove', (WidgetTester tester) async {
      await tester.pumpWidget(materialApp);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      verify(
        materialApp.blacklistBloc.dispatch(Remove(initialValue)),
      ).called(1);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/widget/status/sleep_buttons.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(child: SleepButtons());
  });

  testWidgets('shows disable button for BlocStateSuccess<Status> enabled',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusEnabled));
    await tester.pumpWidget(materialApp);

    expect(find.text('Disable'), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.text('10 seconds'), findsOneWidget);
    await tester.tap(find.text('10 seconds'));

    await tester.tap(find.text('Custom time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
  });

  testWidgets('permanently disable button', (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusEnabled));
    await tester.pumpWidget(materialApp);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Permanently'));
  });

  testWidgets('shows play button for BlocStateSuccess<Status> disabled',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusDisabled));
    await tester.pumpWidget(materialApp);

    expect(find.text('Enable'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
  });

  testWidgets('shows wake button for StatusStateSleeping',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState).thenAnswer((_) =>
        StatusStateSleeping(Duration(minutes: 2, seconds: 5), Stopwatch()));
    await tester.pumpWidget(materialApp);

    expect(find.text('Wake (0:02:05)'), findsOneWidget);

    await tester.pump(new Duration(seconds: 50));
    await tester.tap(find.byType(ListTile));
  });

  testWidgets('shows disable button without onTap for BlocStateError<Status>',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateError<Status>());
    await tester.pumpWidget(materialApp);

    final titleFinder = find.text('Disable');

    expect(titleFinder, findsOneWidget);
  });
}

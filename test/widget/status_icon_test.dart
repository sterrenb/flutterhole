import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/widget/status/status_icon.dart';
import 'package:mockito/mockito.dart';

import '../mock.dart';
import 'mock.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    BlocSupervisor.delegate = SimpleBlocDelegate();
  });

  testWidgets('StatusIcon', (WidgetTester tester) async {
    final child = StatusIcon(color: Colors.purple);
    materialApp = MockMaterialApp(child: child);
    await tester.pumpWidget(materialApp);

    expect((find.byWidget(child).evaluate().first.widget as StatusIcon).color,
        Colors.purple);
  });

  group('VersionsStatusIcon', () {
    testWidgets('grey for BlocStateLoading<Versions>',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: VersionsStatusIcon());
      when(materialApp.versionsBloc.currentState)
          .thenAnswer((_) => BlocStateLoading<Versions>());
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.grey);
    });
    testWidgets('green for BlocStateSuccess<Versions>',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: VersionsStatusIcon());
      when(materialApp.versionsBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<Versions>(mockVersions));
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.green);
    });

    testWidgets('red for BlocStateError<Versions>',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: VersionsStatusIcon());
      when(materialApp.versionsBloc.currentState)
          .thenAnswer((_) => BlocStateError<Versions>());
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.red);
    });
  });

  group('ActiveStatusIcon', () {
    testWidgets('grey for BlocStateLoading<Status>',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: ActiveStatusIcon());
      when(materialApp.statusBloc.currentState)
          .thenAnswer((_) => BlocStateLoading<Status>());
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.grey);
    });
    testWidgets('green for BlocStateSuccess<Status> enabled',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: ActiveStatusIcon());
      when(materialApp.statusBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusEnabled));
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.green);
    });

    testWidgets('orange for BlocStateSuccess<Status> disabled',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: ActiveStatusIcon());
      when(materialApp.statusBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusDisabled));
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.orange);
    });

    testWidgets('orange for StatusStateSleeping', (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: ActiveStatusIcon());
      when(materialApp.statusBloc.currentState).thenAnswer(
          (_) => StatusStateSleeping(Duration(seconds: 1), Stopwatch()));
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.orange);
    });

    testWidgets('red for BlocStateError<Status>', (WidgetTester tester) async {
      materialApp = MockMaterialApp(child: ActiveStatusIcon());
      when(materialApp.statusBloc.currentState)
          .thenAnswer((_) => BlocStateError<Status>());
      await tester.pumpWidget(materialApp);

      expect(
          (find.byType(StatusIcon).evaluate().first.widget as StatusIcon).color,
          Colors.red);
    });
  });
}

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/widget/status/toggle_button.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  ToggleButton toggleButton;
  MockMaterialApp materialApp;

  setUp(() {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    toggleButton = ToggleButton();
    materialApp = MockMaterialApp(child: toggleButton);
  });

  testWidgets('shows CircularProgressIndicator for BlocStateLoading<Status>',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<Status>());
    await tester.pumpWidget(materialApp);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows refresh button for BlocStateEmpty<Status> ',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<Status>());
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.refresh), findsOneWidget);
    await tester.tap(find.byWidget(toggleButton));
  });

  testWidgets('shows pause button for BlocStateSuccess<Status> enabled',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusEnabled));
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.pause), findsOneWidget);
    await tester.tap(find.byWidget(toggleButton));
  });

  testWidgets('shows play button for BlocStateSuccess<Status> enabled',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Status>(mockStatusDisabled));
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.tap(find.byWidget(toggleButton));
  });

  testWidgets('shows play button for StatusStateSleeping',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState).thenAnswer(
        (_) => StatusStateSleeping(Duration(seconds: 1), Stopwatch()));
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.tap(find.byWidget(toggleButton));
  });

  testWidgets('shows play button for BlocStateError<Status>',
      (WidgetTester tester) async {
    when(materialApp.statusBloc.currentState)
        .thenAnswer((_) => BlocStateError<Status>());
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.error), findsOneWidget);
    await tester.tap(find.byWidget(toggleButton));
  });
}

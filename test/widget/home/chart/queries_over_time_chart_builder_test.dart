import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/queries_over_time.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/home/chart/queries_over_time_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/queries_over_time_line_chart.dart';
import 'package:mockito/mockito.dart';

import '../../../mock.dart';
import '../../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(child: QueriesOverTimeChartBuilder());
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateEmpty<QueriesOverTime>',
      (WidgetTester tester) async {
    when(materialApp.queriesOverTimeBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<QueriesOverTime>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateLoading<QueriesOverTime>',
      (WidgetTester tester) async {
    when(materialApp.queriesOverTimeBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<QueriesOverTime>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows warning Card for BlocStateError<QueriesOverTime>',
      (WidgetTester tester) async {
    when(materialApp.queriesOverTimeBloc.currentState)
        .thenAnswer((_) => BlocStateError<QueriesOverTime>(PiholeException()));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets(
      'shows Container for BlocStateError<QueriesOverTime> with PiholeException("API token is empty"',
      (WidgetTester tester) async {
    when(materialApp.queriesOverTimeBloc.currentState).thenAnswer((_) =>
        BlocStateError<QueriesOverTime>(
            PiholeException(message: 'API token is empty')));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Container), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets(
      'shows QueriesOverTimeLineChart for BlocStateSuccess<QueriesOverTime>',
      (WidgetTester tester) async {
    when(materialApp.queriesOverTimeBloc.currentState).thenAnswer(
        (_) => BlocStateSuccess<QueriesOverTime>(mockQueriesOverTime));
    await tester.pumpWidget(materialApp);
    expect(find.byType(QueriesOverTimeLineChart), findsOneWidget);
  });
}

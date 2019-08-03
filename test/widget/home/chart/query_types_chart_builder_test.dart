import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/home/chart/pi_chart.dart';
import 'package:flutterhole/widget/home/chart/query_types_chart_builder.dart';
import 'package:mockito/mockito.dart';

import '../../../mock.dart';
import '../../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(child: QueryTypesChartBuilder());
  });

  testWidgets('shows CircularProgressIndicator for BlocStateEmpty<QueryTypes>',
      (WidgetTester tester) async {
    when(materialApp.queryTypesBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<QueryTypes>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateLoading<QueryTypes>',
      (WidgetTester tester) async {
    when(materialApp.queryTypesBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<QueryTypes>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows warning Card for BlocStateError<QueryTypes>',
      (WidgetTester tester) async {
    when(materialApp.queryTypesBloc.currentState)
        .thenAnswer((_) => BlocStateError<QueryTypes>(PiholeException()));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets(
      'shows Container for BlocStateError<QueryTypes> with PiholeException("API token is empty"',
      (WidgetTester tester) async {
    when(materialApp.queryTypesBloc.currentState).thenAnswer((_) =>
        BlocStateError<QueryTypes>(
            PiholeException(message: 'API token is empty')));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Container), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('shows PiChart for BlocStateSuccess<QueryTypes>',
      (WidgetTester tester) async {
    when(materialApp.queryTypesBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<QueryTypes>(mockQueryTypes));
    await tester.pumpWidget(materialApp);
    expect(find.byType(PiChart), findsOneWidget);
  });
}

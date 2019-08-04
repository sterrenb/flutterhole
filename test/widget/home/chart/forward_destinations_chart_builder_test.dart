import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/forward_destinations.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/home/chart/forward_destinations_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/pi_chart.dart';
import 'package:mockito/mockito.dart';

import '../../../mock.dart';
import '../../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(child: ForwardDestinationsChartBuilder());
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateEmpty<ForwardDestinations>',
      (WidgetTester tester) async {
    when(materialApp.forwardDestinationsBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<ForwardDestinations>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateLoading<ForwardDestinations>',
      (WidgetTester tester) async {
    when(materialApp.forwardDestinationsBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<ForwardDestinations>());
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows warning Card for BlocStateError<ForwardDestinations>',
      (WidgetTester tester) async {
    when(materialApp.forwardDestinationsBloc.currentState).thenAnswer(
        (_) => BlocStateError<ForwardDestinations>(PiholeException()));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets(
      'shows Container for BlocStateError<ForwardDestinations> with PiholeException("API token is empty"',
      (WidgetTester tester) async {
    when(materialApp.forwardDestinationsBloc.currentState).thenAnswer((_) =>
        BlocStateError<ForwardDestinations>(
            PiholeException(message: 'API token is empty')));
    await tester.pumpWidget(materialApp);
    expect(find.byType(Container), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
  });

  testWidgets('shows PiChart for BlocStateSuccess<ForwardDestinations>',
      (WidgetTester tester) async {
    when(materialApp.forwardDestinationsBloc.currentState).thenAnswer(
        (_) => BlocStateSuccess<ForwardDestinations>(mockForwardDestinations));
    await tester.pumpWidget(materialApp);
    expect(find.byType(PiChart), findsOneWidget);
  });
}

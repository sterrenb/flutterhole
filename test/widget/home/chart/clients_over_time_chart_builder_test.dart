import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_chart_builder.dart';
import 'package:flutterhole/widget/home/chart/clients_over_time_line_chart_builder.dart';
import 'package:mockito/mockito.dart';

import '../../../mock.dart';
import '../../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    Globals.tree = MockMemoryTree();
    materialApp = MockMaterialApp(child: ClientsOverTimeChartBuilder());
  });

  testWidgets('shows CircularProgressIndicator for BlocStateEmpty',
      (WidgetTester tester) async {
//    when(materialApp.clientsOverTimeBloc.currentState)
//        .thenAnswer((_) => BlocStateEmpty<ClientsOverTime>());
//    when(materialApp.clientNamesBloc.currentState)
//        .thenAnswer((_) => BlocStateEmpty<ClientNames>());
    when(materialApp.clientsOverTimeBloc.hasCache).thenReturn(false);
    when(materialApp.clientNamesBloc.hasCache).thenReturn(false);

    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'shows CircularProgressIndicator for BlocStateLoading<ClientsOverTime>',
      (WidgetTester tester) async {
    when(materialApp.clientsOverTimeBloc.hasCache).thenReturn(false);
    when(materialApp.clientNamesBloc.hasCache).thenReturn(false);
    await tester.pumpWidget(materialApp);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows warning for BlocStateError<ClientsOverTime>',
      (WidgetTester tester) async {
    when(materialApp.clientsOverTimeBloc.currentState)
        .thenAnswer((_) => BlocStateError<ClientsOverTime>(PiholeException()));
    await tester.pumpWidget(materialApp);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testWidgets(
      'shows ClientsOverTimeLineChart for BlocStateSuccess<ClientsOverTime>',
      (WidgetTester tester) async {
    when(materialApp.clientsOverTimeBloc.hasCache).thenReturn(true);
    when(materialApp.clientNamesBloc.hasCache).thenReturn(true);
    when(materialApp.clientsOverTimeBloc.cache).thenReturn(mockClientsOverTime);
    when(materialApp.clientNamesBloc.cache).thenReturn(mockClientNames);
//    when(materialApp.clientNamesBloc.currentState)
//        .thenAnswer((_) => BlocStateSuccess<ClientNames>(mockClientNames));
//    when(materialApp.clientsOverTimeBloc.currentState).thenAnswer(
//        (_) => BlocStateSuccess<ClientsOverTime>(mockClientsOverTime));
    await tester.pumpWidget(materialApp);
    expect(find.byType(ClientsOverTimeLineChartBuilder), findsOneWidget);
  });
}

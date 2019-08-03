import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/search_options.dart';
import 'package:flutterhole/widget/query/query_log_builder.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    materialApp = MockMaterialApp(child: QueryLogBuilder());
  });

  testWidgets('shows empty list for BlocStateEmpty<List<Query>>',
      (WidgetTester tester) async {
    when(materialApp.queryBloc.currentState)
        .thenAnswer((_) => BlocStateEmpty<List<Query>>());

    await tester.pumpWidget(materialApp);

    expect(find.byType(QueryExpansionTile), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows ErrorMessage for BlocStateError<List<Query>>',
      (WidgetTester tester) async {
    when(materialApp.queryBloc.currentState)
        .thenAnswer((_) => BlocStateError<List<Query>>(PiholeException()));

    await tester.pumpWidget(materialApp);

    expect(find.byType(QueryExpansionTile), findsNothing);
    expect(find.byType(ErrorMessage), findsOneWidget);
  });

  group('BlocStateSuccess<List<Query>>', () {
    setUp(() {
      materialApp = MockMaterialApp(
          child: Provider<SearchOptions>.value(
        value: SearchOptions(), // str
        child: QueryLogBuilder(),
      ));
    });

    testWidgets('shows empty list for BlocStateSuccess<List<Query>> empty',
        (WidgetTester tester) async {
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>([]));

      await tester.pumpWidget(materialApp);

      expect(find.byType(QueryExpansionTile), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows list for BlocStateSuccess<List<Query>> with data',
        (WidgetTester tester) async {
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>(mockQueries));

      await tester.pumpWidget(materialApp);

      expect(
        find.byType(QueryExpansionTile),
        findsNWidgets(mockQueries.length),
      );
    });

    testWidgets(
        'shows sublist for BlocStateSuccess<List<Query>> with data and search',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          child: Provider<SearchOptions>.value(
        value: SearchOptions(mockQueries.first.entry), // str
        child: QueryLogBuilder(),
      ));
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>(mockQueries));

      await tester.pumpWidget(materialApp);

      expect(
        find.byType(QueryExpansionTile),
        findsOneWidget,
      );
    });

    testWidgets(
        'shows warning for BlocStateSuccess<List<Query>> with data and empty search result',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          child: Provider<SearchOptions>.value(
        value: SearchOptions('unknown'), // str
        child: QueryLogBuilder(),
      ));
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>(mockQueries));

      await tester.pumpWidget(materialApp);

      expect(
        find.byType(QueryExpansionTile),
        findsNothing,
      );
      expect(find.text('No queries found.'), findsOneWidget);
    });

    testWidgets(
        'shows list for BlocStateSuccess<List<Query>> with data and client filter',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          child: Provider<SearchOptions>.value(
        value: SearchOptions(), // str
        child: QueryLogBuilder(
          filterType: FilterType.Client,
          searchString: mockQueries.first.client,
        ),
      ));
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>(mockQueries));

      await tester.pumpWidget(materialApp);

      expect(
        find.byType(QueryExpansionTile),
        findsNWidgets(mockQueries.length),
      );
    });

    testWidgets(
        'shows list for BlocStateSuccess<List<Query>> with data and queryType filter',
        (WidgetTester tester) async {
      materialApp = MockMaterialApp(
          child: Provider<SearchOptions>.value(
        value: SearchOptions(), // str
        child: QueryLogBuilder(
          filterType: FilterType.QueryType,
          searchString: 'A',
        ),
      ));
      when(materialApp.queryBloc.currentState)
          .thenAnswer((_) => BlocStateSuccess<List<Query>>(mockQueries));

      await tester.pumpWidget(materialApp);

      expect(
        find.byType(QueryExpansionTile),
        findsNWidgets(mockQueries.length),
      );
    });
  });
}

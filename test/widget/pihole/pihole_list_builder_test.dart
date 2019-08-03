import 'package:bloc/bloc.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/bloc/simple_bloc_delegate.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock.dart';

class MockRouter extends Mock implements Router {}

void main() {
  MockMaterialApp materialApp;

  setUpAll(() {
    Globals.client = MockPiholeClient();
    Globals.router = MockRouter();
  });

  setUp(() {
    BlocSupervisor.delegate = SimpleBlocDelegate();
    materialApp = MockMaterialApp(child: PiholeListBuilder());
  });

  testWidgets('shows empty list for PiholeStateEmpty',
      (WidgetTester tester) async {
    when(materialApp.piholeBloc.currentState)
        .thenAnswer((_) => PiholeStateEmpty());

    await tester.pumpWidget(materialApp);

    expect(find.byType(PiholeTile), findsNothing);
  });

  testWidgets('shows ErrorMessage for PiholeStateError',
      (WidgetTester tester) async {
    when(materialApp.piholeBloc.currentState)
        .thenAnswer((_) => PiholeStateError());

    await tester.pumpWidget(materialApp);

    expect(find.byType(ErrorMessage), findsOneWidget);
  });

  testWidgets('shows empty list for PiholeStateSuccess empty',
      (WidgetTester tester) async {
    when(materialApp.piholeBloc.currentState)
        .thenAnswer((_) => PiholeStateSuccess(all: [], active: null));

    await tester.pumpWidget(materialApp);

    expect(find.byType(PiholeTile), findsNothing);
    expect(find.text('No configurations found.'), findsOneWidget);
  });

  testWidgets('shows removable list for PiholeStateSuccess',
      (WidgetTester tester) async {
    when(materialApp.piholeBloc.currentState)
        .thenAnswer((_) => PiholeStateSuccess(
              all: mockPiholes,
              active: mockPiholes.last,
            ));

    await tester.pumpWidget(materialApp);

    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(mockPiholes.length));

    // active a configuration
    await tester.longPress(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));

    // edit a configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));

    // dismiss a configuration
    final String title = mockPiholes.first.title;
    expect(find.text(title), findsOneWidget);
    await tester.drag(find.byType(Dismissible).first, Offset(500.0, 0.0));
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);
  });

  testWidgets('shows fixed list for PiholeStateSuccess when editable = false',
      (WidgetTester tester) async {
    materialApp = MockMaterialApp(child: PiholeListBuilder(editable: false));
    when(materialApp.piholeBloc.currentState)
        .thenAnswer((_) => PiholeStateSuccess(
              all: mockPiholes,
              active: mockPiholes.last,
            ));

    await tester.pumpWidget(materialApp);

    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);

    // edit a configuration
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));
    expect(find.byType(SnackBar), findsOneWidget);

    // activate a configuration
    await tester.longPress(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    expect(find.byType(PiholeTile), findsNWidgets(mockPiholes.length));
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

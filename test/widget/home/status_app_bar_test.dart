import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/widget/status/status_app_bar.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock.dart';

void main() {
  MockMaterialApp materialApp;

  setUp(() {
    materialApp = MockMaterialApp(appbar: StatusAppBar());
  });

  testWidgets('StatusAppBar has default title', (WidgetTester tester) async {
    when(materialApp.piholeBloc.currentState).thenAnswer(
        (_) => PiholeStateSuccess(all: mockPiholes, active: mockPiholes.first));
    await tester.pumpWidget(materialApp);

    final titleFinder = find.text('FlutterHole');

    expect(titleFinder, findsOneWidget);
  });

  testWidgets('StatusAppBar has title', (WidgetTester tester) async {
    materialApp = MockMaterialApp(appbar: StatusAppBar(title: 'TEST'));
    when(materialApp.piholeBloc.currentState).thenAnswer(
        (_) => PiholeStateSuccess(all: mockPiholes, active: mockPiholes.first));
    await tester.pumpWidget(materialApp);

    final titleFinder = find.text('TEST');

    expect(titleFinder, findsOneWidget);
  });
}

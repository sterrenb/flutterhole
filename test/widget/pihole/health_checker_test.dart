import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:flutterhole/widget/pihole/health_checker.dart';
import 'package:mockito/mockito.dart';

import '../../mock.dart';
import '../mock_material_app.dart';

void main() {
  HealthChecker healthChecker;
  MockMaterialApp materialApp;

  setUp(() {
    healthChecker = HealthChecker();
    materialApp = MockMaterialApp(child: healthChecker);
  });

  testWidgets('shows error for BlocStateError<Versions',
      (WidgetTester tester) async {
    when(materialApp.versionsBloc.currentState)
        .thenAnswer((_) => BlocStateError<Versions>(PiholeException()));
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.error), findsOneWidget);

    // tap to launch url
    await tester.tap(find.byIcon(Icons.web));

    // tap to view error dialog
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.byIcon(Icons.error));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // tap to copy to clipboard
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows loading for BlocStateLoading<Versions',
      (WidgetTester tester) async {
    when(materialApp.versionsBloc.currentState)
        .thenAnswer((_) => BlocStateLoading<Versions>());
    await tester.pumpWidget(materialApp);

    expect(find.text('Loading...'), findsNWidgets(3));
  });

  testWidgets('shows versions for BlocStateSuccess<Versions',
      (WidgetTester tester) async {
    when(materialApp.versionsBloc.currentState)
        .thenAnswer((_) => BlocStateSuccess<Versions>(mockVersions));
    await tester.pumpWidget(materialApp);

    expect(find.byIcon(Icons.error), findsNothing);
    expect(find.text(mockVersions.coreCurrent), findsOneWidget);
    expect(find.text(mockVersions.webCurrent), findsOneWidget);
    expect(find.text(mockVersions.ftlCurrent), findsOneWidget);
  });
}

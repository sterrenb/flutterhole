import 'package:fluro/fluro.dart';
import 'package:flutterhole_again/screen/summary_screen.dart';

const String rootPath = '/';
const String summaryPath = '/summary';

void configureRoutes(Router router) {
  router.notFoundHandler = Handler(handlerFunc: (_, __) {
    print('route not found');
  });

  router.define(rootPath,
      handler: Handler(handlerFunc: (_, __) => SummaryScreen()));
}

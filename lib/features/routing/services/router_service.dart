import 'package:flutter/widgets.dart';

abstract class RouterService {
  static const String home = '/';
  static const String settings = '/settings';
  static const String allPiholes = '/all-piholes';
  static const String log = '/log';
  static const String about = '/about';
  static const String privacy = '/privacy';

  GlobalKey<NavigatorState> get navigatorKey;

  RouteFactory get onGenerateRoute;

  /// Typically called before [runApp].
  void createRoutes();

  Future<T> push<T>(String routeName);

  Future<T> pushFromRoot<T>(String routeName);
}

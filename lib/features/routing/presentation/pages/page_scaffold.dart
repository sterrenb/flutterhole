import 'package:flutter/material.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/features/routing/presentation/widgets/double_back_to_close_app.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';

class PageScaffold extends StatelessWidget {
  /// A [Scaffold] that uses the active pihole theme,
  /// and adds double back to close app.
  const PageScaffold({
    Key key,
    this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.drawer = const DefaultDrawer(),
    this.isNested = false,
  }) : super(key: key);

  final Widget body;
  final PreferredSizeWidget appBar;
  final Widget drawer;
  final Widget bottomNavigationBar;
  final Widget floatingActionButton;
  final bool isNested;

  @override
  Widget build(BuildContext context) {
    return PiholeThemeBuilder(
      child: Scaffold(
        drawer: isNested ? null : drawer,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        body: isNested ? body : DoubleBackToCloseApp(child: body),
      ),
    );
  }
}

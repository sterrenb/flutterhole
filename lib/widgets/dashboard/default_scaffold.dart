import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/refresh_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/toggle_status_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_drawer.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/default_end_drawer.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/status_title.dart';

/// The default scaffold, using the [DefaultDrawer] and the [ToggleStatusButton].
class DefaultScaffold extends StatelessWidget {
  /// The human friendly title, defaults to the active configuration name.
  final String title;

  /// The body of the scaffold.
  final Widget body;

  /// The FAB, defaults to null.
  final Widget fab;

  const DefaultScaffold({
    Key key,
    @required this.body,
    this.title,
    this.fab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: StatusTitle(title: title),
          actions: <Widget>[
            RefreshButton(),
            ToggleStatusButton(),
          ],
        ),
        drawer: DefaultDrawer(),
        endDrawer: DefaultEndDrawer(),
        floatingActionButton: fab,
        body: body);
  }
}

import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/title_row.dart';
import 'package:flutterhole/widget/status/toggle_button.dart';

class StatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const StatusAppBar({
    Key key,
    this.title,
    this.actions = const [],
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: TitleIconRow(title: title,), actions: [
      ...actions,
      ...[ToggleButton()]
    ]);
  }
}

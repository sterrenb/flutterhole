import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/title_row.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';

class DefaultEndDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      UserAccountsDrawerHeader(
        accountName: TitleRow(),
        accountEmail: null,
        onDetailsPressed: null,
      ),
      Expanded(
        child: PiholeListBuilder(
          editable: false,
        ),
      ),
    ]));
  }
}

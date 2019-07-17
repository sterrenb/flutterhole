import 'package:flutter/material.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';
import 'package:flutterhole/widget/status/status_icon.dart';

class DefaultEndDrawer extends StatefulWidget {
  @override
  _DefaultEndDrawerState createState() => _DefaultEndDrawerState();
}

class _DefaultEndDrawerState extends State<DefaultEndDrawer> {
  Pihole active;

  @override
  void initState() {
    super.initState();
    active = Globals.localStorage.active();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      UserAccountsDrawerHeader(
        accountName: Row(
          children: <Widget>[
            Flexible(
                child: Text(
              active == null ? 'FlutterHole' : active.title,
              overflow: TextOverflow.fade,
            )),
            StatusIcon(),
          ],
        ),
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

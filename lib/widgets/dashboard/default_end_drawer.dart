import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';

class DefaultEndDrawer extends StatefulWidget {
  const DefaultEndDrawer({
    Key key,
  }) : super(key: key);

  @override
  _DefaultEndDrawerState createState() => _DefaultEndDrawerState();
}

class _DefaultEndDrawerState extends WithAppState<DefaultEndDrawer> {
  Future<List<Widget>> drawerEndConfigs(BuildContext context) async {
    final int activeIndex = await globalPiConfig(context).getActiveIndex();
    final List<String> all = await globalPiConfig(context).getAll();

    List<Widget> list = [];

    int i = 0;
    all.forEach((configName) {
      final int index = i;
      list.add(ListTile(
        enabled: i != activeIndex,
        leading: i == activeIndex
            ? Icon(Icons.check)
            : Opacity(
                opacity: 0.0,
                child: Icon(Icons.check),
              ),
        onTap: () {
          globalPiConfig(context)
              .switchConfig(context: context, index: index)
              .then((didSwitch) {
            print('switched');
          });
        },
        title: Text(configName),
      ));
      i++;
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Drawer(
      child: FutureBuilder<List<Widget>>(
        future: drawerEndConfigs(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> items = [
              DrawerHeader(
                child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select configuration')),
              ),
            ];
            final List<Widget> x = List.from(items)
              ..addAll(snapshot.data)
              ..addAll([
                Divider(),
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add new configuration'),
                  onTap: () => openEditDialog(context, controller),
                )
              ]);
            return ListView(
              padding: EdgeInsets.zero,
              children: x,
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}

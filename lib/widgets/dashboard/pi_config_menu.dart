import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/edit_form.dart';

const addNew = 'addNew';

class ConfigOption {
  final String name;
  final int index;

  @override
  String toString() {
    return '$name - ${index.toString()}';
  }

  ConfigOption(this.name, this.index);
}

class PiConfigMenu extends StatefulWidget {
  const PiConfigMenu({
    Key key,
  }) : super(key: key);

  @override
  PiConfigMenuState createState() {
    return new PiConfigMenuState();
  }
}

class PiConfigMenuState extends WithAppState<PiConfigMenu> {


  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return FutureBuilder(
      future: Future.wait([
        globalPiConfig(context).getActiveIndex(),
        globalPiConfig(context).getAll(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final int active = snapshot.data[0];
          final List<String> all = snapshot.data[1];
          List<PopupMenuEntry<ConfigOption>> menuItems = [];

          int i = 0;
          all.forEach((String configName) {
            menuItems.add(CheckedPopupMenuItem(
                value: ConfigOption(configName, i),
                checked: i == active,
                enabled: i != active,
                child: Text(configName)));
            i++;
          });

          menuItems.add(PopupMenuDivider());
          menuItems.add(PopupMenuItem(
              value: ConfigOption(addNew, -1),
              child: Text('Add new configuration')));

          return PopupMenuButton<ConfigOption>(
              tooltip: 'Select Pi-hole configuration',
              onSelected: (ConfigOption result) {
                if (result.name == addNew) {
                  return openEditDialog(context, controller);
                } else {
                  globalPiConfig(context)
                      .switchConfig(context: context, index: result.index)
                      .then((bool didSwitch) {
                    setState(() {});
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                return menuItems;
              });
        }

        return CircularProgressIndicator();
      },
    );
  }
}

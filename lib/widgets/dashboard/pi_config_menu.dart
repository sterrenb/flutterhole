import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';

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

class PiConfigMenuState extends State<PiConfigMenu> {
  Future<int> _addNew(String name) async {
    return PiConfig.setConfig(name).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _switchConfig(int index) {
    PiConfig.setActiveIndex(index).then((bool didSet) {
      setState(() {});
      AppState.of(context).resetSleeping();
      AppState.of(context).updateStatus();
      PreferenceIsDark().get().then((dynamic value) {
        PreferenceIsDark.applyTheme(context, value as bool);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: PiConfig.getAll(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          List<PopupMenuEntry<ConfigOption>> menuItems = [];
          PiConfig.getActiveIndex().then((int active) {
            int i = 0;
            snapshot.data.forEach((String configName) {
              menuItems.add(CheckedPopupMenuItem(
                  value: ConfigOption(configName, i),
                  checked: i == active,
                  child: Text(configName)));
              i++;
            });

            menuItems.add(PopupMenuDivider());
            menuItems.add(PopupMenuItem(
                value: ConfigOption(addNew, -1),
                child: Text('Add new configuration')));
          });
          return PopupMenuButton<ConfigOption>(
              tooltip: 'Select Pi-hole configuration',
              onSelected: (ConfigOption result) {
                print('click ${result.toString()}');

                if (result.name == addNew) {
                  // TODO use some user dialog here
                  _addNew('final').then((int newConfigIndex) {
                    _switchConfig(newConfigIndex);
                  });
                } else {
                  _switchConfig(result.index);
                }
              },
              itemBuilder: (BuildContext context) {
                return menuItems;
              });
        }

        return Icon(
          Icons.more_vert,
          color: Colors.red,
        );
      },
    );
  }
}

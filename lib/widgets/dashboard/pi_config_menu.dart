import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';

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
  _addNew(String name) async {
    PiConfig.addConfig(name).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: PiConfig.getAll(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.hasData) {
          List<PopupMenuEntry<ConfigOption>> menuItems = [];
          PiConfig.getActive().then((int active) {
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
                child: Text('Add new Pi-hole')));
          });
          return PopupMenuButton<ConfigOption>(
              tooltip: 'Select Pi-hole configuration',
              onSelected: (ConfigOption result) {
                print('click ${result.toString()}');

                if (result.name == addNew) {
                  // TODO use some user dialog here
                  _addNew('final');
                  setState(() {});
                } else {
                  PiConfig.setActive(result.index).then((bool didSet) {
                    setState(() {});
                  });
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

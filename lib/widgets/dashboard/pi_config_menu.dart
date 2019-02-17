import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/cancel_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_form.dart';
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
      PiConfig.getActiveString().then((String activeString) =>
          Fluttertoast.showToast(msg: 'Switching to $activeString'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

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
                  enabled: i != active,
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
                  return _openPreferenceDialog(context, controller);
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

  /// Shows an [AlertDialog] with an editable preference field
  Future _openPreferenceDialog(BuildContext context,
      TextEditingController controller) {
    final formKey = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertConfigDialog(
              EditForm(formKey: formKey, controller: controller, type: String),
              context);
        });
  }

  AlertDialog alertConfigDialog(EditForm editForm, BuildContext context) {
    List<Widget> actions = [
      CancelButton(),
      FlatButton(
        child: Text('OK'),
        onPressed: () {
          if (editForm.formKey.currentState.validate()) {
            print('set correctly: ${editForm.controller.value.text}');
            _addNew(editForm.controller.value.text).then((int newConfigIndex) {
              _switchConfig(newConfigIndex);
            });
            Navigator.pop(context);
          }
        },
      )
    ];

    return AlertDialog(
      title: Text('Enter a name'),
      content: editForm,
      actions: actions,
    );
  }
}

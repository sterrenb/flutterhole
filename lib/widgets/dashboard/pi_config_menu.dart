import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/dashboard/buttons/cancel_button.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_form.dart';

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
  Future<int> _addNew(String name) async {
    return AppState
        .of(context)
        .piConfig
        .setConfig(name)
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    List<PopupMenuEntry<ConfigOption>> menuItems = [];

    return FutureBuilder(
      future: Future.wait([
        globalPiConfig(context).getActiveIndex(),
        globalPiConfig(context).getAll(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final int active = snapshot.data[0];
          final List<String> all = snapshot.data[1];

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
                  return _openPreferenceDialog(context, controller);
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
            _addNew(editForm.controller.value.text).then((int newConfigIndex) {
              globalPiConfig(context)
                  .switchConfig(context: context, index: newConfigIndex)
                  .then((bool didSwitch) {
                setState(() {});
              });
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_is_dark.dart';

class ResetButton extends StatelessWidget {
  final Function(BuildContext context) onPressed;
  final Widget child;
  final Color color;

  const ResetButton({
    Key key,
    this.onPressed,
    @required this.child,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              onPressed: () {
                onPressed(context);
              },
              child: child,
              color: color,
            ),
          ),
        )
      ],
    );
  }
}

class ResetPrefsButton extends ResetButton {
  static Future<bool> _warningReset(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset all configurations?'),
          content: Text('Your current preferences will be lost.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Reset'),
              onPressed: () {
                Navigator.of(context).pop();
                SharedPreferences.getInstance().then((preferences) {
                  preferences.clear().then((didClear) {
                    if (didClear) {
                      Preference.resetAll();
                      Fluttertoast.showToast(msg: 'Factory reset');
                      AppState.of(context).updateStatus();
                      AppState.of(context)
                          .preferenceIsDark
                          .get()
                          .then((dynamic isDark) {
                        PreferenceIsDark.applyTheme(context, isDark as bool);
                      });
                    } else {
                      Fluttertoast.showToast(msg: 'Failed to factory reset');
                    }
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  ResetPrefsButton()
      : super(
            child: Text('Reset to default settings'),
            onPressed: (BuildContext context) {
              return _warningReset(context);
            });
}

class RemoveConfigButton extends ResetButton {
  RemoveConfigButton()
      : super(
            child: Text('Remove current configuration'),
            color: Colors.orange,
            onPressed: (BuildContext context) {
              PiConfig.removeActiveConfig().then((bool didRemove) {
                if (didRemove) {
                  PiConfig.switchConfig(context: context, pop: false);
                }
              });
            });
}

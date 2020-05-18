import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:preferences/switch_preference.dart';

class UseNumbersApiSwitchPreference extends StatelessWidget {
  const UseNumbersApiSwitchPreference({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchPreference(
      'Use numbers API',
      KPrefs.useNumbersApi,
      defaultVal: true,
      desc:
          'If enabled, the dashboard will fetch number trivia from the Numbers API.',
    );
  }
}

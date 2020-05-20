import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:preferences/preferences.dart';

class FooterMessageStringPreference extends StatelessWidget {
  const FooterMessageStringPreference({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldPreference(
      'Footer message',
      KPrefs.footerMessage,
      hintText: 'Shown at the bottom fo the drawer',
      defaultVal: 'Made with ♡ by Sterrenburg',
    );
  }
}

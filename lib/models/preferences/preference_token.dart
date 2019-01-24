import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreferenceToken extends Preference {
  PreferenceToken()
      : super(
            key: 'token',
            title: 'API token',
            description:
            'Used for enabling/disabling your Pi-hole',
      iconData: Icons.vpn_key,
      onSet: (bool didSet, BuildContext context) {
        AppState.of(context).updateAuthorized().then((bool isAuthorized) {
          String msg = isAuthorized
              ? 'You can now enable/disable your Pi-hole!'
              : 'Cannot authorize - is your API token correct?';
          Fluttertoast.showToast(msg: msg);
        });
      });
}

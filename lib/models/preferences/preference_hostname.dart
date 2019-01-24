import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

class PreferenceHostname extends Preference {
  PreferenceHostname()
      : super(
            key: 'hostname',
            title: 'Hostname',
            description: 'The hostname or IP address of your Pi-hole',
      iconData: Icons.home,
      onSet: (bool didSet, BuildContext context) {
        AppState.of(context).updateStatus();
        AppState.of(context).updateAuthorized();
      });
}

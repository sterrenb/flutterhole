import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

class PreferencePort extends Preference {
  PreferencePort()
      : super(
            key: 'port',
            title: 'Port',
            description: 'The port of your Pi-hole admin dashboard',
            iconData: Icons.adjust);
}

import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// a scaffold for managing a preference that is saved between sessions, using [SharedPreferences].
class PreferenceIsDark extends Preference {
  PreferenceIsDark()
      : super(
          id: 'isDark',
          title: 'Dark Theme',
          description: 'Use the global dark theme',
          help: Container(),
          iconData: Icons.lightbulb_outline,
        );
}

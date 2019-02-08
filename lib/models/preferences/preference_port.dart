import 'package:flutter/material.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

/// A [Preference] for storing the Pi-hole® port.
class PreferencePort extends PreferenceInt {
  final int defaultValue = 80;

  PreferencePort()
      : super(
      id: 'port',
      title: 'Port',
      description: 'The port of your Pi-hole® admin dashboard',
      help: RichText(
          text: TextSpan(
              style: Preference.helpStyle,
              text:
              'The port of the Pi-hole® web browser. Defaults to 80 (http) or 443 (https/SSL).')),
      iconData: Icons.adjust,
      onSet: ({BuildContext context, bool didSet, dynamic value}) {
        AppState.of(context).updateStatus();
        AppState.of(context).updateAuthorized();
      });
}

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// A [Preference] for storing the Pi-hole® API path.
class PreferenceApiPath extends Preference {
  final String defaultValue = 'admin/api.php';

  PreferenceApiPath()
      : super(
            id: 'apiPath',
            title: 'API path',
            description: 'The path from the domain root to the Pi-Hole API. ',
            help: RichText(
                text: TextSpan(
                    style: Preference.helpStyle,
                    text:
                        'Unless you altered your Pi-hole installation, the default value is usually OK. Adjust at your own risk!')),
            iconData: Icons.code,
            onSet: ({BuildContext context, bool didSet, dynamic value}) {
              AppState.of(context).updateStatus();
              AppState.of(context).updateAuthorized();
            });
}

import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/pi_config.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// A [Preference] for storing the Pi-hole® hostname.
class PreferenceConfigName extends Preference {
  final String defaultValue = 'New configuration';

  PreferenceConfigName()
      : super(
            id: 'configName',
            title: 'Configuration name',
            description: 'A unique identifier for this configuration',
            help: Text(
                'A unique identifier for this configuration, for example \'Home\' or \'Office\'.'),
            iconData: Icons.info,
            onSet: ({BuildContext context, bool didSet, dynamic value}) {
              AppState.of(context).updateStatus();
              AppState.of(context).updateAuthorized();
            });

  @override
  Future<dynamic> get() async {
    print('get config name');
    return await (PiConfig.getActiveString());
  }

  @override
  Future<bool> set({dynamic value}) {
    return PiConfig.updateActiveConfig(value as String);
  }
}

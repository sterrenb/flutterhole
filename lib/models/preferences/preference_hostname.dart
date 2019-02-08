import 'package:flutter/material.dart';
import 'package:flutter_hole/models/api_provider.dart';
import 'package:flutter_hole/models/app_state.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

/// A [Preference] for storing the Pi-hole® hostname.
class PreferenceHostname extends Preference {
  final String defaultValue = 'pi.hole';

  PreferenceHostname()
      : super(
      id: 'hostname',
      title: 'Hostname',
      description: 'The hostname or IP address of your Pi-hole',
      help: RichText(
        text: TextSpan(
            text:
            'If you are using Pi-hole® as a DNS server, the hostname is usually ',
            style: Preference.helpStyle,
            children: [
              ApiProvider.hyperLink('http://pi.hole'),
              TextSpan(
                  text: '. Otherwise, it is the IP address, for example ',
                  children: [
                    ApiProvider.hyperLink('http://10.0.1.2'),
                    TextSpan(text: '.')
                  ]),
            ]),
      ),
      iconData: Icons.home,
      onSet: (bool didSet, BuildContext context) {
        AppState.of(context).updateStatus();
        AppState.of(context).updateAuthorized();
      });
}

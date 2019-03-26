import 'package:flutter/material.dart';
import 'package:sterrenburg.github.flutterhole/api/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

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
      onSet: ({BuildContext context, bool didSet, dynamic value}) {
        AppState.of(context).updateStatus();
        AppState.of(context).updateAuthorized();
      });
}

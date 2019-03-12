import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sterrenburg.github.flutterhole/api_provider.dart';
import 'package:sterrenburg.github.flutterhole/widgets/app_state.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference.dart';

/// A [Preference] for storing the Pi-hole® API token.
class PreferenceToken extends Preference {
  PreferenceToken()
      : super(
      id: 'token',
            title: 'API token',
      description: 'Enabling/disabling Pi-hole',
      help: RichText(
        text: TextSpan(
            style: Preference.helpStyle,
            text:
            'To enable and disable Pi-hole® from your device, you need to request an API token. \n\nIn a browser, visit the token generator (usually the \'Show API token \' button at ',
            children: [
              ApiProvider.hyperLink(
                  'http://pi.hole/admin/settings.php?tab=api'),
              TextSpan(
                  text:
                  ') and either select the \'Scan QR code\' button during editing, or copy it manually.\n\nNote that the token is stored on your device storage, and is not sent outside your device\'s network.')
            ]),
      ),
      iconData: Icons.vpn_key,
      onSet: ({BuildContext context, bool didSet, dynamic value}) {
        AppState.of(context).updateAuthorized().then((bool isAuthorized) {
          String msg = isAuthorized
              ? 'Authorization successful'
              : 'Authorizatation failed';
          // toast is needed because the context does not contain a Scaffold for a SnackBar
          Fluttertoast.showToast(msg: msg);
        });
      });
}

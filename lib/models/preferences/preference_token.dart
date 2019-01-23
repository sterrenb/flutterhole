import 'package:flutter/material.dart';
import 'package:flutter_hole/models/preferences/preference.dart';

class PreferenceToken extends Preference {
  PreferenceToken()
      : super(
            key: 'token',
            title: 'API token',
            description:
                'Used fpr authorized actions such as enabling/disabling',
            iconData: Icons.vpn_key);
}

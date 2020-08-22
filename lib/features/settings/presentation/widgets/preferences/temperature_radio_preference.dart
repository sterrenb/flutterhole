import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:preferences/preferences.dart';

class TemperatureRadioPreference extends StatelessWidget {
  const TemperatureRadioPreference();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioPreference(
          'Celsius (°C)',
          'celsius',
          KPrefs.temperatureType,
          isDefault: true,
        ),
        RadioPreference(
          'Fahrenheit (°F)',
          'fahrenheit',
          KPrefs.temperatureType,
        ),
      ],
    );
  }
}

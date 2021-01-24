import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';

class PiTemperatureText extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final temperatureReading = useProvider(temperatureReadingProvider).state;
    final option = useProvider(piDetailsOptionProvider).state;

    return Tooltip(
      message: option.fold(
          () => '',
          (details) =>
              '${details.temperatureInCelcius} | ${details.temperatureInFahrenheit} | ${details.temperatureInKelvin}'),
      child: Text(option.fold(() => '', (details) {
        switch (temperatureReading) {
          case TemperatureReading.celcius:
            return details.temperatureInCelcius;
          case TemperatureReading.fahrenheit:
            return details.temperatureInFahrenheit;
          case TemperatureReading.kelvin:
          default:
            return details.temperatureInKelvin;
        }
      })),
    );
  }
}

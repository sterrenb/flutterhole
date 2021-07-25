import 'package:animations/animations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension DoubleX on double {
  double _celciusToKelvin(double temp) => temp + 273.15;

  double _celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

  String get temperatureInCelcius => '${toStringAsFixed(1)} °C';

  String get temperatureInFahrenheit =>
      '${_celciusToFahrenheit(this).toStringAsFixed(1)} °F';

  String get temperatureInKelvin =>
      '${_celciusToKelvin(this).toStringAsFixed(1)} °K';

  String temperatureInReading(TemperatureReading reading) {
    switch (reading) {
      case TemperatureReading.celcius:
        return temperatureInCelcius;
      case TemperatureReading.fahrenheit:
        return temperatureInFahrenheit;
      case TemperatureReading.kelvin:
      default:
        return temperatureInKelvin;
    }
  }
}

String _temperatureReadingToString(TemperatureReading temperatureReading) {
  switch (temperatureReading) {
    case TemperatureReading.celcius:
      return 'Celcius (°C)';
    case TemperatureReading.fahrenheit:
      return 'Fahrenheit (°F)';
    case TemperatureReading.kelvin:
    default:
      return 'Kelvin (°K)';
  }
}

class TemperatureScaleDropdownButton extends HookWidget {
  const TemperatureScaleDropdownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    final selected = useState(settings.userPreferences.temperatureReading);
    return DropdownButton<TemperatureReading>(
        value: selected.value,
        onChanged: (update) {
          if (update != null) {
            context.read(settingsNotifierProvider.notifier).saveUserPreferences(
                settings.userPreferences.copyWith(temperatureReading: update));
          }
        },
        items: TemperatureReading.values
            .map<DropdownMenuItem<TemperatureReading>>((e) => DropdownMenuItem(
                  child: Text(_temperatureReadingToString(e)),
                  value: e,
                ))
            .toList());
  }
}

class TemperatureRangeDialog extends HookWidget {
  const TemperatureRangeDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void pop(RangeValues? values) => Navigator.of(context).pop(values);
    final theme = Theme.of(context);

    final settings = useProvider(settingsNotifierProvider);
    final currentRange = useState(RangeValues(
        settings.userPreferences.temperatureMin,
        settings.userPreferences.temperatureMax));
    // TODO remove option
    final option = none(); // useProvider(piDetailsOptionProvider).state;

    return DialogBase(
      onSelect: () => pop(currentRange.value),
      onCancel: () => pop(null),
      theme: theme,
      header: const DialogHeader(
        title: 'Temperature',
        message: 'Displays the Pi-hole CPU temperature',
      ),
      body: Column(
        children: [
          ListTile(
            title: option.fold(
              () => Container(),
              (a) => Text(
                  '${(a.temperature ?? 0).temperatureInReading(settings.userPreferences.temperatureReading)}'),
            ),
            trailing: const TemperatureScaleDropdownButton(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12.0),
              const Icon(Icons.ac_unit),
              Expanded(
                child: RangeSlider(
                  values: currentRange.value,
                  min: 0,
                  max: 100,
                  divisions: settings.userPreferences.temperatureReading ==
                          TemperatureReading.fahrenheit
                      ? 180
                      : 100,
                  labels: RangeLabels(
                    currentRange.value.start.temperatureInReading(
                        settings.userPreferences.temperatureReading),
                    currentRange.value.end.temperatureInReading(
                        settings.userPreferences.temperatureReading),
                  ),
                  onChanged: (RangeValues changed) {
                    if ((changed.start - changed.end).abs() >= 2) {
                      currentRange.value = changed;
                      // activeRange.state = changed;
                    }
                  },
                ),
              ),
              const Icon(Icons.local_fire_department),
              const SizedBox(width: 12.0),
            ],
          ),
        ],
      ),
    );
  }
}

Future<RangeValues?> showTemperatureRangeDialog(
        BuildContext context, Reader read) =>
    showModal<RangeValues>(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(),
      builder: (context) => const TemperatureRangeDialog(),
    );

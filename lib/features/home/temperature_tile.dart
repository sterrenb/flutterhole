import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dashboard_tiles.dart';

String _temperatureReadingToScale(TemperatureReading temperatureReading) {
  switch (temperatureReading) {
    case TemperatureReading.celcius:
      return '°C';
    case TemperatureReading.fahrenheit:
      return '°F';
    case TemperatureReading.kelvin:
    default:
      return '°K';
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

Future<void> showTemperatureReadingDialog(
    BuildContext context, Reader read) async {
  final temperatureReading = read(temperatureReadingProvider);
  final selectedTemperatureReading = await showConfirmationDialog(
    context: context,
    title: 'Temperature scale',
    message: 'Used for the Pi-hole CPU temperature',
    initialSelectedActionKey: temperatureReading.state,
    actions: [
      AlertDialogAction<TemperatureReading>(
        key: TemperatureReading.celcius,
        label: '${_temperatureReadingToString(TemperatureReading.celcius)}',
      ),
      AlertDialogAction<TemperatureReading>(
        key: TemperatureReading.fahrenheit,
        label: '${_temperatureReadingToString(TemperatureReading.fahrenheit)}',
      ),
      AlertDialogAction<TemperatureReading>(
        key: TemperatureReading.kelvin,
        label: '${_temperatureReadingToString(TemperatureReading.kelvin)}',
      ),
    ],
  );

  if (selectedTemperatureReading != null) {
    temperatureReading.state = selectedTemperatureReading;
  }
}

class TemperatureScaleDropdownButton extends HookWidget {
  const TemperatureScaleDropdownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reading = useProvider(temperatureReadingProvider);

    return DropdownButton<TemperatureReading>(
        value: reading.state,
        onChanged: (reading) {
          if (reading != null) {
            context.read(temperatureReadingProvider).state = reading;
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
    required this.initialValue,
  }) : super(key: key);

  final RangeValues initialValue;

  @override
  Widget build(BuildContext context) {
    void pop(RangeValues? values) => Navigator.of(context).pop(values);
    final theme = Theme.of(context);

    final currentRange = useState(initialValue);
    final activeRange = useProvider(temperatureRangeProvider);
    final rangeEnabled = useProvider(temperatureRangeEnabledProvider);
    final reading = useProvider(temperatureReadingProvider);
    final option = useProvider(piDetailsOptionProvider).state;

    return DialogBase(
      onSelect: () => pop(currentRange.value),
      onCancel: () => pop(initialValue),
      theme: theme,
      header: DialogHeader(
        title: 'Temperature',
        message: 'Displays the Pi-hole CPU temperature',
      ),
      body: Column(
        children: [
          ListTile(
            title: option.fold(
              () => Container(),
              (a) =>
                  Text('${a.temperature.temperatureInReading(reading.state)}'),
            ),
            trailing: TemperatureScaleDropdownButton(),
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
                  divisions: reading.state == TemperatureReading.fahrenheit
                      ? 180
                      : 100,
                  labels: RangeLabels(
                    currentRange.value.start
                        .temperatureInReading(reading.state),
                    currentRange.value.end.temperatureInReading(reading.state),
                  ),
                  onChanged: rangeEnabled.state
                      ? (RangeValues changed) {
                          if ((changed.start - changed.end).abs() >= 2) {
                            currentRange.value = changed;
                            activeRange.state = changed;
                          }
                        }
                      : null,
                ),
              ),
              const Icon(Icons.local_fire_department),
              const SizedBox(width: 12.0),
            ],
          ),
        ],
      ),
      extraButtons: [
        // TextButton(
        //   child: Text(
        //     rangeEnabled.state ? 'DISABLE' : 'ENABLE',
        //   ),
        //   onPressed: () {
        //     rangeEnabled.state = !rangeEnabled.state;
        //   },
        // ),
      ],
    );
  }
}

Future<void> showTemperatureRangeDialog(
    BuildContext context, Reader read) async {
  final selectedRange = await showModal<RangeValues>(
    context: context,
    configuration: FadeScaleTransitionConfiguration(),
    builder: (context) => TemperatureRangeDialog(
        initialValue: read(temperatureRangeProvider).state),
  );

  if (selectedRange != null) {
    print('setting $selectedRange');
    read(temperatureRangeProvider).state = selectedRange;
  }
}

class TemperatureTile extends HookWidget {
  Color temperatureRangeToColor(RangeValues values, double temperature) {
    if (temperature < values.start) return KColors.temperatureLow;
    if (temperature < values.end) return KColors.temperatureMed;
    return KColors.temperatureHigh;
  }

  @override
  Widget build(BuildContext context) {
    final temperatureReading = useProvider(temperatureReadingProvider).state;
    final temperatureRange = useProvider(temperatureRangeProvider).state;
    final temperatureRangeEnabled =
        useProvider(temperatureRangeEnabledProvider).state;
    final detailsOption = useProvider(piDetailsOptionProvider).state;
    return Card(
      child: AnimatedContainer(
        duration: kThemeChangeDuration * 2,
        color: detailsOption.fold(
            () => KColors.temperatureMed,
            (details) => temperatureRangeEnabled
                ? temperatureRangeToColor(temperatureRange, details.temperature)
                : KColors.temperatureMed),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // onTap: () {
            //   // showTemperatureRangeDialog(context, context.read);
            //   showTemperatureReadingDialog(context, context.read);
            // },
            onLongPress: () {
              showTemperatureRangeDialog(context, context.read);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 10,
                  child: Container(
                      // color: Colors.red,
                      height: 10,
                      child: SliderTheme(
                          data: SliderThemeData(
                            disabledActiveTrackColor: Colors.white,
                            disabledInactiveTrackColor: Colors.white,
                            disabledThumbColor: Colors.white,
                            trackHeight: 1.0,
                            // thumbShape: RoundSliderThumbShape(
                            //   disabledThumbRadius: 5.0,
                            //   elevation: 0,
                            // ),
                            thumbShape: SliderComponentShape.noOverlay,
                          ),
                          child: detailsOption.fold(
                              () => Container(),
                              (details) => Opacity(
                                    opacity: 0.5,
                                    child: Slider(
                                      onChanged: null,
                                      min: 0,
                                      max: 100,
                                      value: details.temperature,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.blue,
                                    ),
                                  )))),
                ),
                TextTileContent(
                  top: 'Temperature',
                  bottom: TextTileBottomText(
                      detailsOption.fold(() => '---', (details) {
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
                  iconData: KIcons.temperatureReading,
                  iconTop: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

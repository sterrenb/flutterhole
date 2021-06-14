import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dashboard_tiles.dart';

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
    BuildContext context,
    TemperatureReading initial,
    ValueChanged<TemperatureReading> onSelected) async {
  final selectedTemperatureReading = await showConfirmationDialog(
    context: context,
    title: 'Temperature scale',
    message: 'Used for the Pi-hole CPU temperature',
    initialSelectedActionKey: initial,
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
    return onSelected(selectedTemperatureReading);
  }
}

class TemperatureScaleDropdownButton extends HookWidget {
  const TemperatureScaleDropdownButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    final selected = useState(settings.preferences.temperatureReading);
    return DropdownButton<TemperatureReading>(
        value: selected.value,
        onChanged: (update) {
          if (update != null) {
            context.read(settingsNotifierProvider.notifier).savePreferences(
                settings.preferences.copyWith(temperatureReading: update));
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
        settings.preferences.temperatureMin,
        settings.preferences.temperatureMax));
    final option = useProvider(piDetailsOptionProvider).state;

    return DialogBase(
      onSelect: () => pop(currentRange.value),
      onCancel: () => pop(null),
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
              (a) => Text(
                  '${(a.temperature ?? 0).temperatureInReading(settings.preferences.temperatureReading)}'),
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
                  divisions: settings.preferences.temperatureReading ==
                          TemperatureReading.fahrenheit
                      ? 180
                      : 100,
                  labels: RangeLabels(
                    currentRange.value.start.temperatureInReading(
                        settings.preferences.temperatureReading),
                    currentRange.value.end.temperatureInReading(
                        settings.preferences.temperatureReading),
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
      configuration: FadeScaleTransitionConfiguration(),
      builder: (context) => TemperatureRangeDialog(),
    );

class TemperatureTile extends HookWidget {
  const TemperatureTile({
    Key? key,
  }) : super(key: key);

  Color preferencesToTemperatureColor(
      UserPreferences preferences, double? temperature) {
    if (temperature == null) return KColors.unknown;
    if (temperature < preferences.temperatureMin) return KColors.temperatureLow;
    if (temperature < preferences.temperatureMax) return KColors.temperatureMed;
    return KColors.temperatureHigh;
  }

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    // final temperatureReading = useProvider(temperatureReadingProvider).state;
    // final temperatureRange = useProvider(temperatureRangeProvider).state;
    // final temperatureRangeEnabled =
    //     useProvider(temperatureRangeEnabledProvider).state;
    final detailsValue = useProvider(activePiDetailsProvider);
    return Card(
      child: AnimatedContainer(
        duration: kThemeChangeDuration * 2,
        color: detailsValue.when(
          loading: () => KColors.temperatureMed,
          data: (details) => preferencesToTemperatureColor(
              settings.preferences, details.temperature),
          error: (e, s) => KColors.unknown,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: detailsValue.when(
              loading: () => null,
              data: (details) => () {
                String message;
                switch (settings.preferences.temperatureReading) {
                  case TemperatureReading.celcius:
                    message = details.temperatureInCelcius;
                    break;
                  case TemperatureReading.fahrenheit:
                    message = details.temperatureInCelcius;
                    break;
                  case TemperatureReading.kelvin:
                    message = details.temperatureInCelcius;
                }

                print(message);

                ScaffoldMessenger.of(context).showThemedMessageNow(context,
                    message: 'Temperature: ${[
                      details.temperatureInCelcius,
                      details.temperatureInFahrenheit,
                      details.temperatureInKelvin
                    ].join(' | ')}',
                    leading: Icon(KIcons.temperatureReading));
              },
              error: (e, s) => null,
            ),
            onLongPress: () async {
              final selectedRange =
                  await showTemperatureRangeDialog(context, context.read);
              if (selectedRange != null) {
                context
                    .read(settingsNotifierProvider.notifier)
                    .savePreferences(settings.preferences.copyWith(
                      temperatureMin: selectedRange.start,
                      temperatureMax: selectedRange.end,
                    ));
              }
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
                          child: detailsValue.when(
                              loading: () => Container(),
                              error: (e, s) => Container(),
                              data: (details) => Opacity(
                                    opacity: 0.5,
                                    child: Slider(
                                      onChanged: null,
                                      min: 0,
                                      max: 100,
                                      value: details.temperature ?? 0,
                                      activeColor: Colors.blue,
                                      inactiveColor: Colors.blue,
                                    ),
                                  )))),
                ),
                TextTileContent(
                  top: TileTitle(
                    'Temperature',
                    color: Colors.white,
                  ),
                  bottom: TextTileBottomText(detailsValue.when(
                      error: (e, s) => '???',
                      loading: () => '---',
                      data: (details) {
                        switch (settings.preferences.temperatureReading) {
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

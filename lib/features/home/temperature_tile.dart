import 'package:animations/animations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
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

class TemperatureTile extends HookWidget {
  const TemperatureTile({
    Key? key,
  }) : super(key: key);

  Color preferencesToTemperatureColor(
      UserPreferences preferences, PiColorTheme piColors, double? temperature) {
    if (temperature == null) return KColors.unknown;
    if (temperature < preferences.temperatureMin) {
      return piColors.temperatureLow;
    }
    if (temperature < preferences.temperatureMax) {
      return piColors.temperatureMed;
    }
    return piColors.temperatureHigh;
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
      child: PiColorsBuilder(
        builder: (context, piColors, _) => AnimatedContainer(
          duration: kThemeChangeDuration * 2,
          color: detailsValue.when(
            loading: () => KColors.loading,
            data: (details) => preferencesToTemperatureColor(
                settings.userPreferences, piColors, details.temperature),
            error: (e, s) => KColors.unknown,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: detailsValue.when(
                loading: () => null,
                data: (details) => () {
                  ScaffoldMessenger.of(context).showThemedMessageNow(context,
                      message: 'Temperature: ${[
                        details.temperatureInCelcius,
                        details.temperatureInFahrenheit,
                        details.temperatureInKelvin
                      ].join(' | ')}',
                      leading: const Icon(KIcons.temperatureReading));
                },
                error: (e, s) => null,
              ),
              onLongPress: () async {
                final selectedRange =
                    await showTemperatureRangeDialog(context, context.read);
                if (selectedRange != null) {
                  context
                      .read(settingsNotifierProvider.notifier)
                      .saveUserPreferences(settings.userPreferences.copyWith(
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
                    child: SizedBox(
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
                    top: const TileTitle(
                      'Temperature',
                      color: Colors.white,
                    ),
                    bottom: TextTileBottomText(detailsValue.when(
                        error: (e, s) => '???',
                        loading: () => '---',
                        data: (details) {
                          switch (settings.userPreferences.temperatureReading) {
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
      ),
    );
  }
}

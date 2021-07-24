import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dash_tiles.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

extension OptionX on Option<PiDetails> {
  String message(TemperatureReading reading) => fold(() => '-', (details) {
        switch (reading) {
          case TemperatureReading.celcius:
            return details.temperatureInCelcius;
          case TemperatureReading.fahrenheit:
            return details.temperatureInFahrenheit;
          case TemperatureReading.kelvin:
            return details.temperatureInKelvin;
        }
      });
}

Color _preferencesToTemperatureColor(
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

class TempTile extends HookWidget {
  const TempTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final detailsValue = useProvider(activePiDetailsProvider);
    final temperatureReading = useProvider(temperatureReadingProvider);
    final preferences = useProvider(userPreferencesProvider);
    return GridCard(
      child: PiColorsBuilder(
        builder: (context, piColors, child) => AnimatedContainer(
          duration: kThemeChangeDuration,
          curve: Curves.ease,
          color: detailsValue.when(
            loading: () => piColors.loading,
            data: (details) => _preferencesToTemperatureColor(
              preferences,
              piColors,
              details.temperature,
            ),
            error: (e, s) => KColors.unknown,
          ),
          child: child,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 16.0,
              top: 16.0,
              child: GridIcon(
                KIcons.temperatureReading,
                iconColor: kDashTileColor,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: detailsValue.when(
                  loading: () => null,
                  data: (details) => () {
                    ScaffoldMessenger.of(context).showMessageNow(
                      message: 'Temperature: ${[
                        details.temperatureInCelcius,
                        details.temperatureInFahrenheit,
                        details.temperatureInKelvin
                      ].join(' | ')}',
                      leading: const Icon(KIcons.temperatureReading),
                    );
                  },
                  error: (e, s) => () => showErrorDialog(context, e, s),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const TileTitle('Temperature', color: kDashTileColor),
                      AnimatedSwitcher(
                        duration: kThemeAnimationDuration,
                        child: detailsValue.when(
                          data: (details) => Text(
                            (PiDetails details) {
                              switch (temperatureReading) {
                                case TemperatureReading.celcius:
                                  return details.temperatureInCelcius;
                                case TemperatureReading.fahrenheit:
                                  return details.temperatureInFahrenheit;
                                case TemperatureReading.kelvin:
                                default:
                                  return details.temperatureInKelvin;
                              }
                            }(details),
                            style: Theme.of(context).summaryStyle,
                          ),
                          loading: () => const SquareCardLoadingIndicator(),
                          error: (e, s) => Text(
                            '---',
                            style: Theme.of(context).summaryStyle,
                          ),
                        ),
                      ),
                      // ActivePiDetailsCacheBuilder(
                      //     builder: (context, option, _) => Text(
                      //           option.message(reading),
                      //           style: Theme.of(context).summaryStyle,
                      //         )),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: IgnorePointer(
                ignoring: true,
                child: SizedBox(
                    height: 10,
                    child: SliderTheme(
                        data: SliderThemeData(
                          disabledActiveTrackColor: kDashTileColor,
                          disabledInactiveTrackColor: kDashTileColor,
                          disabledThumbColor: kDashTileColor,
                          trackHeight: 1.0,
                          thumbShape: SliderComponentShape.noOverlay,
                        ),
                        child: AnimatedOpacity(
                          duration: kThemeChangeDuration,
                          curve: Curves.ease,
                          opacity: detailsValue.maybeWhen(
                            loading: () => 0.0,
                            orElse: () => 1.0,
                          ),
                          child: detailsValue.when(
                              loading: () => Container(),
                              error: (e, s) => Container(),
                              data: (details) {
                                if (details.temperature == null) {
                                  return Container();
                                } else {
                                  return Opacity(
                                    opacity: 0.5,
                                    child: Slider(
                                      onChanged: null,
                                      min: 0,
                                      max: 100,
                                      value: details.temperature!,
                                    ),
                                  );
                                }
                              }),
                        ))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SquareCardLoadingIndicator extends StatelessWidget {
  const SquareCardLoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      // color: Colors.blueGrey,
      height: 40.0,
      width: 40.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation(kDashTileColor),
          ),
        ),
      ),
    );
  }
}

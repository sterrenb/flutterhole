import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dash_tiles.dart';
import 'package:flutterhole_web/features/pihole/pihole_builders.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/themes/theme_builders.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
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

class TempTile extends HookWidget {
  const TempTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useState(Colors.blueAccent);
    final reading = useProvider(temperatureReadingProvider);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        color.value =
            Colors.accents.elementAt(Random().nextInt(Colors.accents.length));
      });

      return timer.cancel;
    }, const []);

    return GridCard(
      child: PiColorsBuilder(
        builder: (context, piColors, child) => AnimatedContainer(
          duration: kThemeChangeDuration * 8,
          curve: Curves.ease,
          color: color.value,
          child: child,
        ),
        child: Material(
            color: Colors.transparent,
            child: HookBuilder(builder: (context) {
              final x = useProvider(activePiDetailsProvider);
              return InkWell(
                  onTap: () {
                    x.maybeWhen(
                      error: (e, s) => showErrorDialog(context, e, s),
                      orElse: () {},
                    );
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TileTitle('Temp tile', color: kDashTileColor),
                        ActivePiDetailsCacheBuilder(
                            builder: (context, option, _) => Text(
                                  option.message(reading),
                                  style: Theme.of(context).summaryStyle,
                                )),
                      ],
                    ),
                  ));
            })),
      ),
    );
  }
}

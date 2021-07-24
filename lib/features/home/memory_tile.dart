import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import 'dash_tiles.dart';
import 'details_tiles.dart';

extension PiDetailsX on PiDetails {
  String memoryUsagePercentageString() =>
      '${(memoryUsage ?? 0.0).toStringAsFixed(1)}%';
}

class MemoryTile extends HookWidget {
  const MemoryTile({Key? key}) : super(key: key);

  static const double loadWidth = 3.0;
  static const double loadHeight = 10.0;

  String memoryUsageToString(double? memoryUsage) =>
      memoryUsage == null ? '?%' : '${memoryUsage.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiParamsProvider);
    final detailsValue = useProvider(piDetailsProvider(pi));

    // final detailsCache = useState<PiDetails?>(null);
    // useEffect(() {
    //   detailsValue.whenData((value) {
    //     detailsCache.value = value;
    //   });
    // }, [detailsValue, detailsCache]);

    return GridCard(
      color: KColors.memoryUsage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 16.0,
            top: 16.0,
            child: GridIcon(
              KIcons.memoryUsage,
              iconColor: kDashTileColor,
            ),
          ),
          GridInkWell(
            onTap: detailsValue.maybeWhen(
              data: (details) => () {
                ScaffoldMessenger.of(context).showMessageNow(
                    message:
                        'Memory usage: ${details.memoryUsagePercentageString()}',
                    // 'CPU load: ${detailsCache.value!.cpuLoads.map((e) => '${(e * 100).toStringAsFixed(0)}%').join(' | ')}',
                    leading: const Icon(KIcons.memoryUsage));
              },
              orElse: () => null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TileTitle('Memory Usage', color: kDashTileColor),
                AnimatedSwitcher(
                  duration: kThemeAnimationDuration,
                  child: detailsValue.when(
                    data: (details) => Text(
                      details.memoryUsagePercentageString(),
                      style: Theme.of(context).summaryStyle,
                    ),
                    loading: () => const SquareCardLoadingIndicator(),
                    error: (e, s) => Text(
                      '---',
                      style: Theme.of(context).summaryStyle,
                    ),
                  ),
                )
              ],
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
                              if (details.memoryUsage == null) {
                                return Container();
                              } else {
                                return Opacity(
                                  opacity: 0.5,
                                  child: Slider(
                                    onChanged: null,
                                    min: 0,
                                    max: 100,
                                    value: details.memoryUsage!,
                                  ),
                                );
                              }
                            }),
                      ))),
            ),
          )
        ],
      ),
    );
  }
}

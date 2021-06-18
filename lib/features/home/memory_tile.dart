import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryTile extends HookWidget {
  const MemoryTile({Key? key}) : super(key: key);

  static const double loadWidth = 3.0;
  static const double loadHeight = 10.0;

  String memoryUsageToString(double? memoryUsage) =>
      memoryUsage == null ? '?%' : '${memoryUsage.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    final detailsValue = useProvider(piDetailsProvider(pi));

    final detailsCache = useState<PiDetails?>(null);
    useEffect(() {
      detailsValue.whenData((value) {
        return detailsCache.value = value;
      });
    }, [detailsValue, detailsCache]);

    return Card(
      color: KColors.memoryUsage,
      child: InkWell(
        onTap: detailsCache.value == null
            ? null
            : () {
                ScaffoldMessenger.of(context).showThemedMessageNow(context,
                    message:
                        'CPU load: ${detailsCache.value!.cpuLoads.map((e) => '${(e * 100).toStringAsFixed(0)}%').join(' | ')}',
                    leading: Icon(KIcons.memoryUsage));
              },
        child: Stack(
          alignment: Alignment.center,
          children: [
            TextTileContent(
              top: TileTitle(
                'Memory Usage',
                color: Colors.white,
              ),
              bottom: detailsValue.when(
                data: (details) => TextTileBottomText(
                    memoryUsageToString(details.memoryUsage)),
                loading: () => TextTileBottomText(detailsCache.value != null
                    ? memoryUsageToString(detailsCache.value!.memoryUsage)
                    : '-'),
                error: (error, stacktrace) => ExpandableCode(
                  code: error.toString(),
                  singleLine: false,
                ),
              ),
              iconData: KIcons.memoryUsage,
              iconTop: 16.0,
            ),
            Positioned(
              bottom: 10,
              child: Container(
                height: loadHeight,
                // color: Colors.orangeAccent,
                child: Row(
                  children: detailsCache.value == null
                      ? <Widget>[]
                      // : [0.1, 0.0, 0.5, 0.8, 2.2, -0.5]
                      : detailsCache.value!.cpuLoads
                          .map<Widget>((cpuLoad) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        width: loadWidth,
                                        height: loadHeight,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(2.0)),
                                      ),
                                      Container(
                                        width: loadWidth,
                                        height: (loadHeight * 2 * cpuLoad)
                                            .clamp(0, loadWidth),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(2.0),
                                            bottomRight: Radius.circular(2.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

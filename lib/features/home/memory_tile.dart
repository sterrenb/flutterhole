import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryTile extends HookWidget {
  const MemoryTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final option = useProvider(piDetailsOptionProvider).state;
    return Card(
      color: Colors.blueGrey,
      // color: Colors.grey[800],
      child: InkWell(
        onTap: () {},
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                height: 10,
                // color: Colors.lightGreen,
                child: Opacity(
                  opacity: .5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: option.fold(
                        () => [],
                        (a) => a.cpuLoads
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        color: Colors.white,
                                      ),
                                      Container(
                                        height: e * 10 * 5,
                                        width: 10,
                                        color: KColors.temperatureMed,
                                      ),
                                    ],
                                  ),
                                ))
                            .toList()),
                  ),
                ),
              ),
            ),
            TextTileContent(
              top: 'Memory Usage',
              bottom: TextTileBottomText(option.fold(() => '---', (details) {
                print(details);
                if (details.memoryUsage < 0) return '---';
                return '${details.memoryUsage.toStringAsFixed(1)}%';
              })),
              iconData: KIcons.memoryUsage,
              iconTop: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}

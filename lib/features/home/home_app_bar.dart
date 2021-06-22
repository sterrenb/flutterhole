import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/features/settings/pi_builders.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/pihole_endpoint_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    return AppBar(
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      elevation: 0.0,
      titleSpacing: 0.0,
      actions: [
        ThemeModeToggle(),
        IconButton(
            onPressed: () async {
              await context.router.push(SettingsRoute());
            },
            icon: Icon(KIcons.settings)),
      ],
      title: Container(
        // color: Colors.red,
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.greenAccent,
                onTap: () {
                  print('ink');
                },
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textButtonTheme: TextButtonThemeData(
                        style: Theme.of(context)
                            .textButtonTheme
                            .style!
                            .copyWith(
                              textStyle: MaterialStateProperty.resolveWith(
                                  (states) =>
                                      Theme.of(context).textTheme.headline6),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith((states) =>
                                      Theme.of(context).colorScheme.onPrimary),
                            )),
                  ),
                  child: TextButton(
                    onLongPress: () {
                      context.router.pushAndSaveSinglePiRoute(context, pi);
                    },
                    onPressed: () => showActivePiDialog(context, context.read),
                    child: Text(
                      pi.title,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            PiStatusIndicator(
              onTap: () {
                context.read(piholeStatusNotifierProvider.notifier).ping();
              },
            ),
          ],
        ),
      ),
    );
  }
}

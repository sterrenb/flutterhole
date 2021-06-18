import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
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
      title: PiStatusMessenger(
        builder: (context) => Container(
          // color: Colors.red,
          child: Row(
            children: [
              TextButton(
                onLongPress: () =>
                    context.router.pushAndSaveSinglePiRoute(context, pi),
                onPressed: () => showActivePiDialog(context, context.read),
                child: Text(
                  pi.title,
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
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
      ),
    );
  }
}

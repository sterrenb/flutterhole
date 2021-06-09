import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiAvatar extends StatelessWidget {
  const PiAvatar({
    Key? key,
    required this.pi,
    required this.onTap,
  }) : super(key: key);

  final Pi pi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CircleAvatar(
          child: Text(String.fromCharCode(pi.title.runes.first)),
          backgroundColor: pi.primaryColor,
        ),
        ClipOval(
          child: Material(
            color: Colors.transparent,
            child: Tooltip(
              message: pi.title,
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDrawer extends HookWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          HookBuilder(builder: (context) {
            final activePi = useProvider(activePiProvider).state;
            final allPis = useProvider(allPisProvider).state;

            return UserAccountsDrawerHeader(
              accountName: Row(
                children: [
                  ActivePiTitle(),
                  PiStatusIndicator(enabled: false),
                ],
              ),
              accountEmail: null,
              currentAccountPicture: PiAvatar(
                pi: activePi,
                onTap: () {},
              ),
              otherAccountsPictures: allPis
                  .where((element) => element != activePi)
                  .map((currentPi) => PiAvatar(
                        pi: currentPi,
                        onTap: () {
                          context.read(activePiProvider).state = currentPi;
                        },
                      ))
                  .toList(),
            );
          }),
          ListTile(
            title: Text('hi'),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/features/settings/single_pi_page.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiListBuilder extends HookWidget {
  const PiListBuilder({
    Key? key,
    this.controller,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ValueChanged<Pi>? onTap;
  final ValueChanged<Pi>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final active = useProvider(activePiProvider);
    final _pis = useProvider(allPisProvider);
    final pis = _pis;
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: pis.length,
      itemBuilder: (context, index) {
        final pi = pis.elementAt(index);
        return ListTile(
          leading: SizedBox(
            width: 50.0,
            height: 50.0,
            child: Stack(
              // fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Icon(
                  KIcons.dot,
                  color: pi.primaryColor,
                ),
                Positioned(
                  left: 25 - 8 + 8,
                  bottom: 25 - 8 - 8,
                  child: Icon(
                    KIcons.dot,
                    color: pi.accentColor,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          ),
          title: Text(pi.title),
          subtitle: Text(pi.dioBase),
          trailing: AnimatedOpacity(
              opacity: pi.id == active.id ? 1 : 0,
              duration: kThemeChangeDuration,
              child: Icon(KIcons.selected)),
          // onLongPress: () {
          //   context.read(settingsNotifierProvider.notifier).activate(pi.id);
          // },
          onTap: onTap != null ? () => onTap!(pi) : null,
          onLongPress: onLongPress != null ? () => onLongPress!(pi) : null,
        );
      },
    );
  }
}

class AddPiTile extends StatelessWidget {
  const AddPiTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(KIcons.add),
      title: Text('Add a new Pi-hole'),
      onTap: () {
        context.read(settingsNotifierProvider.notifier).savePi(PiModel(
              id: DateTime.now().millisecondsSinceEpoch,
              title: Faker().person.firstName(),
              primaryColor: Colors
                  .primaries[Random().nextInt(Colors.primaries.length)].value,
            ).entity);
      },
      trailing: Icon(KIcons.push),
    );
  }
}

Future<void> showActivePiDialog(BuildContext context, Reader read) async {
  final pi = read(activePiProvider);
  final allPis = read(allPisProvider);

  final selectedPi = await showModal(
      context: context,
      builder: (context) => DialogListBase(
          header: DialogHeader(
            title: 'Select a Pi-hole',
          ),
          body: SliverList(
            delegate: SliverChildListDelegate([
              AddPiTile(),
              PiListBuilder(
                onTap: (pi) {
                  read(settingsNotifierProvider.notifier).activate(pi.id);
                  context.router.pop();
                },
                onLongPress: (pi) {
                  context.router.pushAndSaveSinglePiRoute(context, pi);
                },
              ),
            ]),
          )));

  // final selectedPi = await showConfirmationDialog(
  //   context: context,
  //   title: 'Select Pi-hole',
  //   initialSelectedActionKey: pi,
  //   actions: allPis.map<AlertDialogAction>((dPi) {
  //     return AlertDialogAction(
  //       key: dPi,
  //       label: dPi.title,
  //     );
  //   }).toList(),
  // );

  if (selectedPi != null) {
    context.read(settingsNotifierProvider.notifier).activate(selectedPi.id);
  }
}

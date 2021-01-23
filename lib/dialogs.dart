import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/all.dart';

Future<void> showActivePiDialog(BuildContext context, Reader read) async {
  final pi = read(activePiProvider);
  final allPis = read(allPisProvider);
  final selectedPi = await showConfirmationDialog(
    context: context,
    title: 'Select a Pi-hole',
    initialSelectedActionKey: pi.state,
    actions: allPis.map<AlertDialogAction>((dPi) {
      return AlertDialogAction(
        key: dPi,
        label: '${dPi.title}',
      );
    }).toList(),
  );

  if (selectedPi != null) {
    pi.state = selectedPi;
  }
}

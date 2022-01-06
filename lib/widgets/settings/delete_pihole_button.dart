import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<bool?> showDeletePiholeConfirmationDialog(BuildContext context, Pi pi) =>
    showConfirmationDialog(
      context,
      title: 'Delete ${pi.title}?',
      okLabel: 'Delete',
      okColor: Theme.of(context).colorScheme.error,
    );

class DeletePiholeButton extends HookConsumerWidget {
  const DeletePiholeButton({
    Key? key,
    required this.pi,
  }) : super(key: key);

  final Pi pi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final piholes = ref.read(allPiholesProvider);
    return Visibility(
      visible: piholes.length > 1 && piholes.contains(pi),
      child: IconOutlinedButton(
        iconData: KIcons.delete,
        text: 'Delete',
        color: Theme.of(context).colorScheme.error,
        onPressed: () async {
          if (kDebugMode ||
              await showDeletePiholeConfirmationDialog(context, pi) == true) {
            ref.deletePihole(context, pi);
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdateFrequencyButton extends HookConsumerWidget {
  const UpdateFrequencyButton({
    Key? key,
  }) : super(key: key);

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final selected = await showDialog<int>(
        context: context,
        builder: (context) => const UpdateFrequencyDialog(0, 100));
    if (selected != null) {
      ref
          .read(UserPreferencesNotifier.provider.notifier)
          .setUpdateFrequency(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateFrequency = ref.watch(updateFrequencyProvider);
    return ListTile(
      title: const Text('Update frequency'),
      leading: const Icon(KIcons.updateFrequency),
      onTap: () => _showDialog(context, ref),
      trailing: TextButton(
        child: Text(Formatting.secondsOrElse(updateFrequency, 'Disabled')),
        onPressed: () => _showDialog(context, ref),
      ),
    );
  }
}

class UpdateFrequencyDialog extends HookConsumerWidget {
  const UpdateFrequencyDialog(
    this.min,
    this.max, {
    Key? key,
  })  : assert(min < max),
        super(key: key);

  final int min, max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        useState(ref.read(updateFrequencyProvider).clamp(min, max).toDouble());
    return ModalAlertDialog<int>(
        title: "Update frequency",
        popValue: state.value.toInt(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("The time between automatic updates on the dashboard."),
            const SizedBox(height: 16.0),
            Slider(
              value: state.value,
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: Formatting.secondsOrElse(state.value.toInt(), 'Disabled'),
              onChanged: (value) => state.value = value,
            ),
          ],
        ));
  }
}

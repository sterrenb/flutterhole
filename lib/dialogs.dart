import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showErrorDialog(
    BuildContext context, Object e, StackTrace? s) async {
  await showConfirmationDialog(
      context: context, title: 'Error: $e', message: 'Stacktrace: \n\n$s');
}

Future<void> showFailureDialog(
    BuildContext context, String title, String message) async {
  await showOkAlertDialog(
      context: context, title: 'Error: $title', message: message);
}

Future<void> showActivePiDialog(BuildContext context, Reader read) async {
  final pi = read(activePiProvider);
  final allPis = read(allPisProvider).state;
  final selectedPi = await showConfirmationDialog(
    context: context,
    title: 'Active Pi-hole',
    initialSelectedActionKey: pi.state,
    actions: allPis.map<AlertDialogAction>((dPi) {
      return AlertDialogAction(
        key: dPi,
        label: dPi.title,
      );
    }).toList(),
  );

  if (selectedPi != null) {
    pi.state = selectedPi;
  }
}

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class DialogBase extends HookWidget {
  const DialogBase({
    Key? key,
    required this.header,
    required this.body,
    required this.onSelect,
    required this.onCancel,
    required this.theme,
    this.extraButtons = const [],
  }) : super(key: key);

  final Widget header;
  final Widget body;
  final VoidCallback onSelect;
  final VoidCallback onCancel;
  final ThemeData theme;
  final List<Widget> extraButtons;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: body,
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonBar(
                layoutBehavior: ButtonBarLayoutBehavior.constrained,
                children: extraButtons,
              ),
              ButtonBar(
                layoutBehavior: ButtonBarLayoutBehavior.constrained,
                children: [
                  TextButton(
                    child: Text(
                      MaterialLocalizations.of(context).cancelButtonLabel,
                    ),
                    onPressed: onCancel,
                  ),
                  TextButton(
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                    onPressed: onSelect,
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DurationDialog extends HookWidget {
  final String title;
  final String message;
  final Duration initialValue;
  final ValueChanged<Duration?> onSelect;
  final ThemeData theme;

  const DurationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.initialValue,
    required this.onSelect,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counter = useState(initialValue.inSeconds.toDouble());

    return DialogBase(
      header: DialogHeader(
        title: title,
        message: message,
      ),
      body: Column(
        children: [
          Slider(
            value: counter.value,
            min: 0.0,
            max: 60.0,
            divisions: 60,
            label: counter.value == 0.0
                ? 'Disabled'
                : '${counter.value.round()} seconds',
            onChanged: (value) => counter.value = value,
          ),
          // Text('${counter.value}'),
        ],
      ),
      onSelect: () => onSelect(Duration(seconds: counter.value.round())),
      onCancel: () => onSelect(null),
      theme: theme,
    );
  }
}

Future<void> showUpdateFrequencyDialog(
    BuildContext context, Reader read) async {
  void pop(Duration? key) => Navigator.of(context).pop(key);
  final theme = Theme.of(context);

  final selectedDuration = await showModal<Duration>(
    context: context,
    configuration: FadeScaleTransitionConfiguration(),
    builder: (context) => DurationDialog(
      title: 'Update frequency',
      message: 'Used for refreshing API data, temperature, etc.',
      initialValue: read(updateFrequencyProvider).state,
      onSelect: pop,
      theme: theme,
    ),
  );

  if (selectedDuration != null) {
    read(updateFrequencyProvider).state = selectedDuration;
  }
}

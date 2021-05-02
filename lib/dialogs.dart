import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showErrorDialog(
    BuildContext context, Object e, StackTrace? s) async {
  await showConfirmationDialog(
      context: context, title: 'Error: $e', message: 'Stacktrace: \n\n$s');
}

Future<void> showActivePiDialog(BuildContext context, Reader read) async {
  final pi = read(activePiProvider);
  final allPis = read(allPisProvider);
  final selectedPi = await showConfirmationDialog(
    context: context,
    title: 'Active Pi-hole',
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

Future<void> showUpdateFrequencyDialog(
    BuildContext context, Reader read) async {
  void pop(Duration? key) => Navigator.of(context).pop(key);
  final theme = Theme.of(context);

  const String title = 'Update frequency';
  const String message = 'Used for refreshing API data, temperature, etc.';

  final selectedDuration = await showModal<Duration>(
    context: context,
    configuration: FadeScaleTransitionConfiguration(),
    builder: (context) => DurationDialog(
      title: title,
      message: message,
      initialValue: read(updateFrequencyProvider).state,
      onSelect: pop,
      theme: theme,
    ),
    //     _Dialog(
    //   title: title,
    //   message: message,
    //   theme: theme,
    //   initialKey: Duration(seconds: 15),
    //   onSelect: pop,
    // ),
  );

  if (selectedDuration != null) {
    read(updateFrequencyProvider).state = selectedDuration;
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

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headline6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message,
                    style: theme.textTheme.caption,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Column(
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
          const Divider(height: 0),
          ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: [
              TextButton(
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
                onPressed: () => onSelect(null),
              ),
              TextButton(
                child: Text(
                  MaterialLocalizations.of(context).okButtonLabel,
                ),
                onPressed: () =>
                    onSelect(Duration(seconds: counter.value.round())),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _Dialog<T> extends StatefulWidget {
  const _Dialog({
    Key? key,
    required this.title,
    required this.message,
    required this.initialKey,
    required this.onSelect,
    required this.theme,
  }) : super(key: key);

  final String title;
  final String message;
  final T initialKey;
  final ValueChanged<T?> onSelect;
  final ThemeData theme;

  @override
  __DialogState<T> createState() => __DialogState<T>();
}

class __DialogState<T> extends State<_Dialog<T>> {
  T? selectedKey;

  @override
  void initState() {
    super.initState();
    selectedKey = widget.initialKey;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: widget.theme.textTheme.headline6,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.message,
                    style: widget.theme.textTheme.caption,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Flexible(
            child: SizedBox(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('Hi'),
                  Text('Hi'),
                  Text('Hi'),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          ButtonBar(
            layoutBehavior: ButtonBarLayoutBehavior.constrained,
            children: [
              TextButton(
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
                onPressed: () => widget.onSelect(null),
              ),
              TextButton(
                child: Text(
                  MaterialLocalizations.of(context).okButtonLabel,
                ),
                onPressed: () => widget.onSelect(selectedKey),
              )
            ],
          )
        ],
      ),
    );
  }
}

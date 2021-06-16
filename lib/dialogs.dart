import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showErrorDialog(
    BuildContext context, Object e, StackTrace? s) async {
  await showConfirmationDialog(
      context: context,
      title: 'Error: $e',
      message: 'Stacktrace: \n\n$s $s $s');
}

Future<void> showFailureDialog(
    BuildContext context, String title, String message) async {
  await showOkAlertDialog(
      context: context, title: 'Error: $title', message: message);
}

Future<void> showActivePiDialog(BuildContext context, Reader read) async {
  final pi = read(activePiProvider);
  final allPis = read(allPisProvider);
  final selectedPi = await showConfirmationDialog(
    context: context,
    title: 'Select Pi-hole',
    initialSelectedActionKey: pi,
    actions: allPis.map<AlertDialogAction>((dPi) {
      return AlertDialogAction(
        key: dPi,
        label: dPi.title,
      );
    }).toList(),
  );

  if (selectedPi != null) {
    context.read(settingsNotifierProvider.notifier).activate(selectedPi.id);
  }
}

class DialogHeader extends StatelessWidget {
  const DialogHeader({
    Key? key,
    required this.title,
    this.message,
  }) : super(key: key);
  final String title;
  final String? message;

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
          Visibility(
            visible: (message != null),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                message ?? '',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BaseButtonRow extends StatelessWidget {
  const BaseButtonRow({
    Key? key,
    required this.onCancel,
    required this.onSelect,
    this.extraButtons = const [],
  }) : super(key: key);

  final List<Widget> extraButtons;
  final VoidCallback onCancel;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            onSelect != null
                ? TextButton(
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                    ),
                    onPressed: onSelect,
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}

class DialogBase extends StatelessWidget {
  const DialogBase({
    Key? key,
    required this.header,
    required this.body,
    required this.onSelect,
    this.onCancel,
    required this.theme,
    this.extraButtons = const [],
  }) : super(key: key);

  final Widget header;
  final Widget body;
  final VoidCallback? onSelect;
  final VoidCallback? onCancel;
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
          BaseButtonRow(
            onCancel: onCancel != null ? onCancel! : () => context.router.pop(),
            onSelect: onSelect,
            extraButtons: extraButtons,
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
            max: 60 * 2,
            divisions: 60 * 2,
            label: counter.value.toInt().secondsOrElse('Disabled'),
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

Future<Duration?> showUpdateFrequencyDialog(
    BuildContext context, Duration initialValue) async {
  void pop(Duration? key) => Navigator.of(context).pop(key);
  final theme = Theme.of(context);

  return showModal<Duration>(
    context: context,
    configuration: FadeScaleTransitionConfiguration(),
    builder: (context) => DurationDialog(
      title: 'Update frequency',
      message: 'The time between automatic updates on the dashboard.',
      initialValue: initialValue,
      onSelect: pop,
      theme: theme,
    ),
  );

  // if (selectedDuration != null) {
  //   read(updateFrequencyProvider).state = selectedDuration;
  // }
}

class DialogListBase extends StatelessWidget {
  const DialogListBase({
    Key? key,
    required this.header,
    required this.body,
    // required this.onSelect,
    // required this.onCancel,
    // required this.theme,
    this.extraButtons = const [],
  }) : super(key: key);

  final Widget header;
  final Widget body;

  // final VoidCallback onSelect;
  // final VoidCallback onCancel;
  // final ThemeData theme;
  final List<Widget> extraButtons;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CustomScrollView(
        shrinkWrap: true,
        // physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: header),
          body,
          // SliverToBoxAdapter(
          //     child: Column(
          //   children: [body],
          // )),
          // const Divider(height: 0),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 8.0),
          //   child: body,
          // ),
          // const Divider(height: 0),
          // SliverToBoxAdapter(
          //   child: BaseButtonRow(
          //     onCancel: onCancel,
          //     onSelect: onSelect,
          //     extraButtons: extraButtons,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.onConfirm,
    required this.body,
    this.onCancel,
  }) : super(key: key);

  final String title;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      header: DialogHeader(title: title),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: body,
      ),
      onSelect: () async {
        context.router.pop();
        onConfirm();
      },
      onCancel: onCancel,
      theme: Theme.of(context),
    );
  }
}

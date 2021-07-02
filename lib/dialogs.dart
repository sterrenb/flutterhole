import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/media_queries.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/formatting.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

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
    this.canCancel = true,
  }) : super(key: key);

  final Widget header;
  final Widget body;
  final VoidCallback? onSelect;
  final VoidCallback? onCancel;
  final ThemeData theme;
  final List<Widget> extraButtons;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.clampedBodyPadding,
      child: Dialog(
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
                    canCancel
                        ? TextButton(
                            child: Text(
                              MaterialLocalizations.of(context)
                                  .cancelButtonLabel,
                            ),
                            onPressed: onCancel != null
                                ? onCancel!
                                : () => context.router.pop(),
                          )
                        : Container(),
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
            )
          ],
        ),
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
        // message: message,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(message),
          ),
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
    configuration: const FadeScaleTransitionConfiguration(),
    builder: (context) => DurationDialog(
      title: 'Update frequency',
      message:
          'The time between automatic updates on the dashboard.\n\nSetting this value too low can cause timeouts.',
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
    return Padding(
      padding: context.clampedBodyPadding.add(context.clampedListPadding),
      child: Dialog(
        child: CustomScrollView(
          shrinkWrap: true,
          // physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: header),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Divider(height: 1),
              ),
            ),
            body,
            // SliverToBoxAdapter(
            //     child: Column(
            //   children: [body],
            // )),
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
    this.canCancel = true,
  }) : super(key: key);

  final String title;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget body;
  final bool canCancel;

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
      canCancel: canCancel,
      theme: Theme.of(context),
    );
  }
}

String _errorToTitle(Object e) {
  if (e is PiholeApiFailure) {
    return e.toString();
  }
  return e.runtimeType.toString();
}

String _errorToDescription(Object e) {
  if (e is PiholeApiFailure) {
    return e.description;
  }
  return e.toString();
}

Future<void> showErrorDialog(BuildContext context, Object e, [StackTrace? s]) =>
    showModal(context: context, builder: (context) => ErrorDialog(e, s));

class ErrorDialog extends HookWidget {
  const ErrorDialog(
    this.e,
    this.s, {
    Key? key,
  }) : super(key: key);

  final Object e;
  final StackTrace? s;

  @override
  Widget build(BuildContext context) {
    return DialogListBase(
        header: const DialogHeader(title: 'Error'),
        // onConfirm: () {},
        body: SliverList(
          // shrinkWrap: true,
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0)
                  .add(const EdgeInsets.only(bottom: 16.0)),
              child: Text(_errorToDescription(e)),
            ),
            HookBuilder(
              builder: (context) {
                final devMode = useProvider(devModeProvider);
                return Tooltip(
                  message: 'Expand stacktrace',
                  child: ExpansionTile(
                    initiallyExpanded: devMode,
                    title: Row(
                      children: [
                        Expanded(
                            child: CodeCard(
                          code: _errorToTitle(e),
                          singleLine: false,
                        )),
                      ],
                    ),
                    children: [
                      SelectableCodeCard(
                        ((s?.toString() ?? 'No stacktrace found.')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),
        ));
  }
}

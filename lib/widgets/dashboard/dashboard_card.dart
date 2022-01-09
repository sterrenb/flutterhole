import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardCardHeader extends HookConsumerWidget {
  final String title;
  final bool isLoading;
  final Object? error;

  const DashboardCardHeader({
    Key? key,
    required this.title,
    required this.isLoading,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(dashboardEntryProvider);
    return Stack(
      alignment: Alignment.centerRight,
      fit: StackFit.passthrough,
      children: [
        ListTile(
          dense: true,
          mouseCursor: SystemMouseCursors.click,
          title: Text(
            title,
            style: (entry.constraints.crossAxisCount > 0
                    ? Theme.of(context).textTheme.subtitle1
                    : Theme.of(context).textTheme.caption)
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
            overflow: TextOverflow.visible,
            // maxLines: 2,
            // softWrap: false,
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: AnimatedLoadingErrorIndicatorIcon(
              mouseCursor: SystemMouseCursors.click,
              isLoading: isLoading,
              error: error,
              title: title,
            )),
      ],
    );
  }
}

class DashboardBackgroundIcon extends StatelessWidget {
  const DashboardBackgroundIcon(
    this.id, {
    Key? key,
  }) : super(key: key);

  final DashboardID id;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Icon(
        id.iconData,
        // size: (constraints.biggest.shortestSide / 2),
        size: constraints.biggest.shortestSide,
        color: Theme.of(context).colorScheme.secondary.withOpacity(.05),
      );
    });
  }
}

class DashboardCard extends HookConsumerWidget {
  const DashboardCard({
    Key? key,
    required this.id,
    required this.content,
    this.header,
    this.onTap,
    this.cardColor,
    this.background,
    this.backgroundAlignment,
  }) : super(key: key);

  final DashboardID id;
  final Widget content;
  final Widget? header;
  final VoidCallback? onTap;
  final Color? cardColor;
  final Widget? background;
  final Alignment? backgroundAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(dashboardEntryProvider);
    return Card(
        color: cardColor,
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            showScrollableConfirmationDialog(
              context,
              canOk: false,
              canCancel: false,
              title: id.humanString,
              contentPadding: EdgeInsets.zero,
              body: ProviderScope(overrides: [
                dashboardEntryProvider.overrideWithValue(entry),
              ], child: _DashboardCardDialog(id: id)),
            );
          },
          child: Stack(
            alignment: backgroundAlignment ?? Alignment.center,
            children: [
              if (background != null) ...[background!],
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header != null) ...[header!],
                  content,
                ],
              ),
            ],
          ),
        ));
  }
}

class _DashboardCardDialog extends HookConsumerWidget {
  const _DashboardCardDialog({
    Key? key,
    required this.id,
  }) : super(key: key);

  final DashboardID id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = useState(ref.read(dashboardEntryProvider));
    final dashboard = ref.watch(piProvider.select((value) => value.dashboard));
    final currentIndex =
        dashboard.indexWhere((element) => element.id == entry.value.id);

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8.0),
          DevWidget(
            child: ListTile(
              title: const Text('Type'),
              trailing: Text(
                entry.value.constraints.map(
                  count: (_) => 'Count',
                  extent: (_) => 'Extent',
                  fit: (_) => 'Fit',
                ),
              ),
            ),
          ),
          CheckboxListTile(
            title: const Text('Enabled'),
            value: entry.value.enabled,
            onChanged: (value) {
              entry.value = entry.value.copyWith(enabled: value ?? false);
              ref.updateDashboardEntry(entry.value);
            },
          ),
          ListTile(
            title: const Text('Width'),
            trailing: NumberToggleButtons(
                onSelected: (index) {
                  entry.value = entry.value.copyWith
                      .constraints(crossAxisCount: index + 1);
                  ref.updateDashboardEntry(entry.value);
                },
                max: 4,
                isSelected: List.generate(
                    4,
                    (index) =>
                        index + 1 == entry.value.constraints.crossAxisCount)),
          ),
          ListTile(
            title: const Text('Height'),
            trailing: entry.value.constraints.when(
              count: (cross, main) => NumberToggleButtons(
                  onSelected: (index) {
                    final update =
                        DashboardTileConstraints.count(cross, index + 1);
                    entry.value = entry.value.copyWith(constraints: update);
                    ref.updateDashboardEntry(entry.value);
                  },
                  max: 4,
                  isSelected: List.generate(4, (index) => index + 1 == main)),
              extent: (cross, extent) => OutlinedButton(
                onPressed: null,
                child: Text('$extent px'),
              ),
              fit: (cross) => const OutlinedButton(
                onPressed: null,
                child: Text('Fit to content'),
              ),
            ),
          ),
          ListTile(
            title: const Text('Position'),
            trailing: ToggleButtons(
                onPressed: (index) {
                  int newIndex = currentIndex;
                  if (index == 0) newIndex++;
                  if (index == 2) newIndex--;
                  ref.moveDashboardEntry(currentIndex, newIndex);
                },
                children: [
                  const Tooltip(
                      message: 'Move down', child: Icon(KIcons.bottom)),
                  Text('${currentIndex + 1}'),
                  const Tooltip(message: 'Move up', child: Icon(KIcons.top)),
                ],
                isSelected: const [
                  false,
                  true,
                  false
                ]),
          ),
        ]);
  }
}

class NumberToggleButtons extends StatelessWidget {
  const NumberToggleButtons({
    Key? key,
    required this.max,
    required this.onSelected,
    required this.isSelected,
  })  : assert(isSelected.length == max),
        super(key: key);

  final int max;
  final ValueChanged<int> onSelected;
  final List<bool> isSelected;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      onPressed: onSelected,
      children: List.generate(max, (index) => Text((index + 1).toString())),
      isSelected: isSelected,
    );
  }
}

class DashboardFittedCard extends StatelessWidget {
  const DashboardFittedCard({
    Key? key,
    required this.id,
    required this.title,
    required this.isLoading,
    this.text,
    this.onTap,
    this.cardColor,
    this.error,
    this.background,
    this.backgroundAlignment,
  }) : super(key: key);

  final DashboardID id;
  final String title;
  final String? text;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color? cardColor;
  final Object? error;
  final Widget? background;
  final Alignment? backgroundAlignment;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      id: id,
      header:
          DashboardCardHeader(title: title, isLoading: isLoading, error: error),
      onTap: onTap,
      cardColor: cardColor,

      content: AnimatedCardContent(
        isLoading: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(8.0)
              .subtract(const EdgeInsets.only(top: 8.0)),
          child: FittedText(text: text ?? ''),
        ),
      ),
      background: background,
      backgroundAlignment: backgroundAlignment,
      // content: const Expanded(child: Center(child: Text('TODO'))),
    );
  }
}

class AnimatedCardContent extends HookConsumerWidget {
  const AnimatedCardContent({
    required this.isLoading,
    required this.child,
    this.loadingIndicator,
    Key? key,
  }) : super(key: key);

  final bool isLoading;
  final Widget child;
  final Widget? loadingIndicator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finishedFirstLoading = useState(false);
    useValueChanged<bool, void>(isLoading, (oldValue, __) {
      finishedFirstLoading.value = isLoading || oldValue;
    });

    return Expanded(
      child: AnimatedFader(
        duration: kThemeAnimationDuration,
        layoutBuilder: AnimatedFader.centerExpandLayoutBuilder,
        child: !finishedFirstLoading.value
            ? (loadingIndicator ?? Container())
            : child,
      ),
    );
  }
}

class FittedText extends StatelessWidget {
  const FittedText({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

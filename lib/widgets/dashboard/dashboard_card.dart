import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/dialogs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardCardHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      mouseCursor: SystemMouseCursors.click,
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
              overflow: TextOverflow.visible,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        ],
      ),
      trailing: AnimatedLoadingErrorIndicatorIcon(
        mouseCursor: SystemMouseCursors.click,
        isLoading: isLoading,
        error: error,
        title: title,
      ),
    );
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
  }) : super(key: key);

  final DashboardID id;
  final Widget content;
  final Widget? header;
  final VoidCallback? onTap;
  final Color? cardColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
        color: cardColor,
        child: InkWell(
          // onTap: onTap,
          onTap: () {
            // print(ref.read(dashboardTileConstraintsProvider(id)));
            showConfirmationDialog(
              context,
              title: id.humanString,
              canCancel: false,
              body: _DashboardCardDialog(id: id),
            );
          },
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[header!],
              content,
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
    final oldValue = ref.read(dashboardTileConstraintsProvider(id));
    final debugMode = ref.read(UserPreferencesNotifier.provider).devMode;
    final constraints = useState(oldValue);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Type'),
            trailing: debugMode
                ? ToggleButtons(
                    onPressed: (index) {},
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('Count'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('Extent'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('Fit'),
                      ),
                    ],
                    isSelected: [
                      constraints.value.maybeMap(
                        count: (_) => true,
                        orElse: () => false,
                      ),
                      constraints.value.maybeMap(
                        extent: (_) => true,
                        orElse: () => false,
                      ),
                      constraints.value.maybeMap(
                        fit: (_) => true,
                        orElse: () => false,
                      ),
                    ],
                  )
                : Text(constraints.value.map(
                    count: (_) => 'Count',
                    extent: (_) => 'Extent',
                    fit: (_) => 'Fit',
                  )),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Width'),
            trailing: NumberToggleButtons(
                onSelected: (index) {
                  constraints.value =
                      constraints.value.copyWith(crossAxisCount: index + 1);
                  ref.updateDashboardTileConstraints(id, constraints.value);
                },
                max: 4,
                isSelected: List.generate(4,
                    (index) => index + 1 == constraints.value.crossAxisCount)),
          ),
          ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Height'),
              trailing: constraints.value.when(
                count: (cross, main) => NumberToggleButtons(
                    onSelected: (index) {
                      constraints.value =
                          DashboardTileConstraints.count(cross, index + 1);
                      ref.updateDashboardTileConstraints(id, constraints.value);
                    },
                    max: 4,
                    isSelected: List.generate(4, (index) => index + 1 == main)),
                extent: (cross, extent) => Text(extent.toString()),
                fit: (cross) => Text('fit'),
              ),
            ),
          ]
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

class DashboardFittedTile extends StatelessWidget {
  const DashboardFittedTile({
    Key? key,
    required this.id,
    required this.title,
    required this.isLoading,
    this.text,
    this.onTap,
    this.cardColor,
    this.error,
  }) : super(key: key);

  final DashboardID id;
  final String title;
  final String? text;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color? cardColor;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      id: id,
      header:
          DashboardCardHeader(title: title, isLoading: isLoading, error: error),
      onTap: onTap,
      cardColor: cardColor,
      content: Expanded(
          child: Padding(
        padding:
            const EdgeInsets.all(8.0).subtract(const EdgeInsets.only(top: 8.0)),
        child: FittedText(text: text ?? '-'),
      )),
      // content: const Expanded(child: Center(child: Text('TODO'))),
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
        // style: GoogleFonts.firaMono(
        //     // fontWeight: FontWeight.bold,
        //     ),
      ),
    );
  }
}

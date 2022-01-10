import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/dashboard_edit_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/layout/loading_indicator.dart';
import 'package:flutterhole/widgets/layout/tab_view.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/periodic_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardAppBar extends HookConsumerWidget with PreferredSizeWidget {
  const DashboardAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static const labels = ['Dashboard', 'Queries'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final currentIndex = ref.watch(tabViewIndexProvider);

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pi.title),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: _StatusIcon(),
          ),
          Expanded(
            child: Opacity(
              opacity: .5,
              child: Stack(
                children: [
                  ...labels.map((label) => AnimatedOpacity(
                        duration: kThemeAnimationDuration,
                        opacity:
                            labels.elementAt(currentIndex) == label ? 1.0 : 0.0,
                        child: Text(
                          label,
                          overflow: TextOverflow.fade,
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        const DevToolBar(),
        DevWidget(
            child: IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            ref.refreshDashboard();
            ref.refreshQueryItems();
          },
          icon: const Icon(KIcons.refresh),
        )),
        const _DashboardPopupMenuButton(),
        const PushViewButton(
          label: 'Settings',
          iconData: KIcons.settings,
          view: SettingsView(),
        ),
      ],
      bottom: const _Bottom(),
    );
  }
}

class _Bottom extends HookConsumerWidget with PreferredSizeWidget {
  const _Bottom({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(4.0);

  static const notLoadingHeight = 0.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final pingStatus = ref.watch(PingNotifier.provider);
    final status = pingStatus.status;
    final remaining = useState(Duration.zero);

    useEffect(() {
      remaining.value = status.maybeWhen(
          sleeping: (duration, start) {
            return duration - now.difference(start);
          },
          orElse: () => Duration.zero);
    }, [status]);

    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      curve: Curves.easeOutCubic,
      height: remaining.value != Duration.zero
          ? preferredSize.height
          : notLoadingHeight,
      child: status.maybeWhen(
        sleeping: (duration, start) {
          return PeriodicWidget(
            interval: const Duration(seconds: 1),
            onTimer: (_) {
              remaining.value = remaining.value - const Duration(seconds: 1);
            },
            builder: (context) {
              final left =
                  remaining.value.inMilliseconds / duration.inMilliseconds;
              return LinearProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                value: left,
              );
            },
          );
        },
        orElse: () => Container(height: 0.0),
      ),
    );
  }
}

class _DashboardPopupMenuButton extends HookConsumerWidget {
  const _DashboardPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final piholes = ref.watch(allPiholesProvider);
    final index = ref.watch(tabViewIndexProvider);
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (selected) {
        if (selected == 'Edit dashboard') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const DashboardEditView(),
            fullscreenDialog: true,
          ));
        }
      },
      itemBuilder: (context) => [
        if (index == 0) ...[
          const PopupMenuItem<String>(
            value: 'Edit dashboard',
            child: MenuIconButton(
              label: 'Edit dashboard',
              iconData: KIcons.editDashboard,
            ),
          ),
          PopupMenuItem(
            onTap: () {
              WebService.launchUrlInBrowser(Formatting.piToAdminUrl(pi));
            },
            child: const MenuIconButton(
              label: 'Open in browser',
              iconData: KIcons.openUrl,
            ),
          ),
        ],
        PopupMenuItem(
          onTap: () {
            switch (index) {
              case 0:
                return ref.refreshDashboard();
              case 1:
                return ref.refreshQueryItems();
            }
          },
          child: const MenuIconButton(
            label: 'Refresh',
            iconData: KIcons.refresh,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'Select',
          enabled: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Select Pi-hole',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        ...piholes
            .map((e) => PopupMenuItem<String>(
                  value: e.title,
                  onTap: () {
                    if (e != pi) {
                      ref
                          .read(UserPreferencesNotifier.provider.notifier)
                          .selectPihole(e);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.title,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Icon(
                        KIcons.selected,
                        color: e == pi
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }
}

class _StatusIcon extends HookConsumerWidget {
  const _StatusIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ping = ref.watch(PingNotifier.provider);
    final status = ping.status;
    final isLoading = ping.loading;

    final color = status.map(
      enabled: (_) => Colors.green,
      disabled: (_) => Colors.orange,
      sleeping: (_) => Colors.blue,
    );

    return Tooltip(
      message: isLoading
          ? 'Loading...'
          : status.when(
              enabled: () => 'Enabled',
              disabled: () => 'Disabled',
              sleeping: (duration, start) =>
                  'Sleeping until ${start.add(duration).hms}',
            ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          DefaultAnimatedOpacity(
              show: isLoading,
              child: LoadingIndicator(
                size: 12.0,
                strokeWidth: 2.0,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(.5),
                // color: Theme.of(context).colorScheme.secondary,
              )),
          Icon(
            KIcons.dot,
            color: color,
            size: 4.0,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/api/ping_api_button.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/query_log/query_log_list.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/scaffold_messenger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dashboard_edit_view.dart';

final _selectedIndexProvider = StateProvider<int>((ref) => 0);

class DashboardView extends HookConsumerWidget {
  const DashboardView({
    Key? key,
  }) : super(key: key);

  static const labels = ['Dashboard', 'Queries', 'Clients'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final selectedIndex = ref.watch(_selectedIndexProvider);
    final page = usePageController(initialPage: selectedIndex);

    useValueChanged<int, void>(selectedIndex, (oldValue, _) {
      page.animateToPage(
        selectedIndex,
        duration: kThemeAnimationDuration * (oldValue - selectedIndex).abs(),
        curve: Curves.easeOutCubic,
      );
    });

    return BaseView(
      child: Scaffold(
        floatingActionButton: const PingFloatingActionButton(),
        appBar: AppBar(
          title: Row(
            children: [
              Text(pi.title + ' '),
              Opacity(
                opacity: .5,
                child: Stack(
                  children: [
                    ...labels.map((e) => AnimatedOpacity(
                          duration: kThemeAnimationDuration,
                          opacity:
                              labels.elementAt(selectedIndex) == e ? 1.0 : 0.0,
                          child: Text(e),
                        ))
                  ],
                ),
              ),
            ],
          ),
          actions: [
            const DevToolBar(),
            DevWidget(
                child: IconButton(
              onPressed: () {
                ref.refreshQueryItems();
              },
              icon: const Icon(KIcons.refresh),
            )),
            const _DashboardPopupMenuButton(),
            const PushViewIconButton(
              tooltip: 'Settings',
              iconData: KIcons.settings,
              view: SettingsView(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(_selectedIndexProvider.state).state = index;
          },
          landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(KIcons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(KIcons.queryLog),
              label: 'Queries',
            ),
            BottomNavigationBarItem(
              icon: Icon(KIcons.clientActivity),
              label: 'Clients',
            ),
          ],
        ),
        extendBody: true,
        body: UnreadNotificationsBanner(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
              ),
              PageView(
                controller: page,
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight * 2 + 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DashboardGrid(entries: pi.dashboard),
                            // const TabFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const QueriesTab(),
                  const ClientsTab(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TabFooter extends StatelessWidget {
  const TabFooter({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: kBottomNavigationBarHeight + 24.0,
        child: Center(
            child: Text(
          'FlutterHole',
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(color: Theme.of(context).primaryColor.withOpacity(.2)),
        )));
  }
}

class QueriesTab extends StatelessWidget {
  const QueriesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MobileMaxWidth(
      child: QueryLogList(),
    );
  }
}

class ClientsTab extends StatelessWidget {
  const ClientsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Clients'),
    );
  }
}

class _DashboardPopupMenuButton extends HookConsumerWidget {
  const _DashboardPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final piholes = ref.watch(allPiholesProvider);
    final index = ref.watch(_selectedIndexProvider);
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (selected) {
        if (selected == 'Manage dashboard') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const DashboardEditView(),
            fullscreenDialog: true,
          ));
        }
      },
      itemBuilder: (context) => [
        if (index == 0) ...[
          PopupMenuItem<String>(
            value: 'Manage dashboard',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Manage dashboard'),
                Icon(
                  KIcons.selectDashboardTiles,
                  color: Theme.of(context).dividerColor,
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            onTap: () {
              WebService.launchUrlInBrowser(Formatting.piToAdminUrl(pi));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Open in browser'),
                Tooltip(
                    message: Formatting.piToAdminUrl(pi),
                    child: Icon(
                      KIcons.openUrl,
                      color: Theme.of(context).dividerColor,
                    )),
              ],
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Refresh'),
              Icon(
                KIcons.refresh,
                color: Theme.of(context).dividerColor,
              ),
            ],
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

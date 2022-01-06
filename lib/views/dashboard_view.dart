import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/scaffold_messenger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dashboard_edit_view.dart';

class DashboardView extends HookConsumerWidget {
  const DashboardView({
    Key? key,
  }) : super(key: key);

  static const labels = ['Dashboard', 'Queries', 'Clients'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final selectedIndex = useState(0);
    final page = usePageController();

    useValueChanged<int, void>(selectedIndex.value, (oldValue, _) {
      page.animateToPage(
        selectedIndex.value,
        duration:
            kThemeAnimationDuration * (oldValue - selectedIndex.value).abs(),
        curve: Curves.easeOutCubic,
      );
    });

    return BaseView(
      child: Scaffold(
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
                          opacity: labels.elementAt(selectedIndex.value) == e
                              ? 1.0
                              : 0.0,
                          child: Text(e),
                        ))
                  ],
                ),
              ),
            ],
          ),
          actions: const [
            _DashPopupMenuButton(),
            PushViewIconButton(
              tooltip: 'Settings',
              iconData: KIcons.settings,
              view: SettingsView(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex.value,
          onTap: (index) {
            selectedIndex.value = index;
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
            children: [
              Container(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
                // child: Center(
                //   child: Text("Center"),
                // ),
              ),
              PageView(
                controller: page,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: kBottomNavigationBarHeight),
                      child: DashboardGrid(entries: pi.dashboard),
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

class QueriesTab extends StatelessWidget {
  const QueriesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Query $index'),
          );
        });
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

class _DashPopupMenuButton extends HookConsumerWidget {
  const _DashPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pi = ref.watch(piProvider);
    final piholes = ref.watch(allPiholesProvider);
    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (selected) {
        if (selected == 'Manage dashboard') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const DashboardEditView(),
            fullscreenDialog: true,
          ));
        } else if (selected == 'Admin page') {
          WebService.launchUrlInBrowser(Formatting.piToAdminUrl(pi));
        }
      },
      itemBuilder: (context) => [
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
          value: 'Admin page',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Admin page'),
              Tooltip(
                  message: Formatting.piToAdminUrl(pi),
                  child: Icon(
                    KIcons.openUrl,
                    color: Theme.of(context).dividerColor,
                  )),
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

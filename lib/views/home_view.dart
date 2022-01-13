import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/api/ping_api_button.dart';
import 'package:flutterhole/widgets/dashboard/app_bar.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/layout/tab_view.dart';
import 'package:flutterhole/widgets/query_log/query_log_list.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/scaffold_messenger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(piProvider.select((value) => value.dashboard));

    return TabView(
      appBar: const DashboardAppBar(),
      floatingActionButton: const PingFloatingActionButton(),
      bottomItems: const [
        BottomNavigationBarItem(
          icon: Icon(KIcons.dashboard),
          label: 'Dashboard',
          tooltip: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(KIcons.queryLog),
          label: 'Queries',
          tooltip: '',
        ),
      ],
      builder: (context, page) => UnreadNotificationsBanner(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Theme.of(context).colorScheme.secondary.withOpacity(.1),
            ),
            PageView(
              controller: page,
              children: [
                DashboardRefreshIndicator(
                  onRefresh: () async {
                    ref.refreshDashboard();
                    await Future.delayed(kThemeAnimationDuration);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(
                              bottom: kBottomNavigationBarHeight + 16.0)
                          .add(const EdgeInsets.all(4.0)),
                      child: DashboardGrid(entries: dashboard),
                    ),
                  ),
                ),
                const QueriesTab(),
                // const ClientsTab(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class QueriesTab extends HookConsumerWidget {
  const QueriesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobileMaxWidth(
      child: DashboardRefreshIndicator(
          onRefresh: () async {
            ref.refreshQueriesTab();
          },
          child: const QueryLogList()),
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

class DashboardRefreshIndicator extends StatelessWidget {
  const DashboardRefreshIndicator({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 20.0,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        await onRefresh();
        await Future.delayed(kThemeAnimationDuration);
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/dashboard/dashboard_grid.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DashboardView extends HookConsumerWidget {
  const DashboardView({
    Key? key,
  }) : super(key: key);

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
          title: Text(pi.title),
          actions: const [
            PushViewIconButton(
              iconData: KIcons.settings,
              view: SettingsView(),
            )
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
        body: Stack(
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
                  child: DashboardGrid(entries: pi.dashboard),
                ),
                const QueriesTab(),
                const ClientsTab(),
              ],
            )
          ],
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

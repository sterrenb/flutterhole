import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/snackbar.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _ThemeModeTile extends HookWidget {
  const _ThemeModeTile({Key? key}) : super(key: key);

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      default:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    return Center(
      child: ListTile(
        leading: Icon(KIcons.lightTheme),
        title: Text('Theme mode'),
        trailing: DropdownButton<ThemeMode>(
          value: themeMode,
          onChanged: (update) {
            if (update != null) {
              context
                  .read(settingsNotifierProvider.notifier)
                  .saveThemeMode(update);
            }
          },
          items: ThemeMode.values
              .map<DropdownMenuItem<ThemeMode>>((e) => DropdownMenuItem(
                    value: e,
                    child: Text(_themeModeToString(e)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _MyPiHolesTile extends HookWidget {
  const _MyPiHolesTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListTile(
        leading: Icon(KIcons.pihole),
        title: Text('My Pi-holes'),
        trailing: Icon(KIcons.push),
        onTap: () {
          AutoRouter.of(context).push(PiEditRoute());
        },
      ),
    );
  }
}

class BetterSettingsPage extends HookWidget {
  const BetterSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<StaggeredTile, Widget> items = {
      // StaggeredTile.extent(4, kToolbarHeight): AppVersionListTile(
      //   title: 'FlutterHole',
      //   showLicences: false,
      // ),
      StaggeredTile.extent(4, kGridSpacing * 2): Container(),
      // StaggeredTile.extent(4, kToolbarHeight):
      //     const GridSectionHeader('Preferences', KIcons.customization),
      StaggeredTile.extent(4, kToolbarHeight): const _MyPiHolesTile(),
      StaggeredTile.extent(4, kToolbarHeight): const _ThemeModeTile(),
      StaggeredTile.extent(4, kToolbarHeight): const _UpdateFrequencyTile(),
      StaggeredTile.count(4, 1):
          const GridSectionHeader('Danger zone', KIcons.dangerZone),
      StaggeredTile.count(2, 1): const _ResetAllSettingsCard(),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: PageGrid(
        // pageController: pageController,
        crossAxisCount: 4,
        tiles: items.keys.toList(),
        children: items.values.toList(),
      ),
    );
  }
}

class _ResetAllSettingsCard extends StatelessWidget {
  const _ResetAllSettingsCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: KColors.error,
      child: GridInkWell(
        onTap: () => showModal(
          context: context,
          builder: (context) => DialogBase(
            header: DialogHeader(title: 'Reset all settings?'),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                  'All your preferences and Pi-holes and will be lost. This could help if the app gets stuck.'),
            ),
            onSelect: () async {
              context.router.pop();
              await context.read(settingsNotifierProvider.notifier).reset();
              ScaffoldMessenger.of(context).showMessageNow(
                context,
                message: 'All settings have been reset',
                leading: const Icon(
                  KIcons.delete,
                  color: KColors.error,
                ),
              );
            },
            theme: Theme.of(context),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(KIcons.delete),
              const SizedBox(width: kGridSpacing),
              Text('Reset all settings'),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateFrequencyTile extends HookWidget {
  const _UpdateFrequencyTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = useProvider(updateFrequencyProvider);
    return ListTile(
      title: Text('Update frequency'),
      leading: Icon(KIcons.updateFrequency),
      trailing: TextButton(
        child: Text(duration.inSeconds == 0
            ? 'Disabled'
            : '${duration.inSeconds} seconds'),
        onPressed: () async {
          final update = await showUpdateFrequencyDialog(context, duration);
          if (update != null) {
            context
                .read(settingsNotifierProvider.notifier)
                .saveUpdateFrequency(update);
          }
        },
      ),
    );
  }
}

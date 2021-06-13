import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';

String themeModeToString(ThemeMode themeMode) {
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

class AppSettingsList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(oldThemeModeProvider);
    final preferences = useProvider(userPreferencesProvider);
    final pi = useProvider(activePiProvider);

    final piSummary = useProvider(piSummaryProvider(pi));
    return SettingsList(
      physics: const BouncingScrollPhysics(),
      sections: [
        CustomSection(child: SizedBox(height: 20.0)),
        CustomSection(
          child: SettingsTile(
            title: 'Active Pi-hole',
            subtitle: '${pi.title}',
            leading: Icon(KIcons.pihole),
            onPressed: (context) => showActivePiDialog(context, context.read),
          ),
        ),
        SettingsSection(
          title: 'Customization',
          tiles: [
            SettingsTile(
              title: "Pi-holes",
              onPressed: (context) {
                AutoRouter.of(context).push(PiEditRoute());
              },
            ),
            buildThemeTile(themeMode),
            // SettingsTile(
            //   title: 'Update frequency',
            //   subtitle: 'Every ${updateFrequency.state.inSeconds} seconds',
            //   leading: Icon(KIcons.updateFrequency),
            //   onPressed: (context) =>
            //       showUpdateFrequencyDialog(context, context.read),
            // ),
            // SettingsTile(
            //   title: 'Temperature reading',
            //   subtitle:
            //       '${_temperatureReadingToString(temperatureReading.state)}',
            //   leading: Icon(KIcons.temperatureReading),
            //   onPressed: (context) =>
            //       showTemperatureReadingDialog(context, preferences.temperatureReading, (update) {
            //         print('TODO');
            //       }),
            // ),
          ],
        ),
        SettingsSection(
          title: 'Annotation',
          tiles: [
            SettingsTile(
              title: 'Title',
              subtitle: 'My Pi-hole',
              leading: Icon(KIcons.piholeTitle),
              onPressed: (context) async {
                await showTextInputDialog(
                  context: context,
                  title: 'Title',
                  textFields: [
                    DialogTextField(),
                    DialogTextField(),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  SettingsTile buildThemeTile(StateController<ThemeMode> themeMode) =>
      SettingsTile(
        title: 'Theme',
        subtitle: '${themeModeToString(themeMode.state)}',
        leading: Icon(KIcons.lightTheme),
        onPressed: (context) async {
          final selectedTheme = await showConfirmationDialog(
            context: context,
            title: 'Theme',
            initialSelectedActionKey: themeMode.state,
            actions: [
              AlertDialogAction<ThemeMode>(
                key: ThemeMode.system,
                label: '${themeModeToString(ThemeMode.system)}',
              ),
              AlertDialogAction<ThemeMode>(
                key: ThemeMode.light,
                label: '${themeModeToString(ThemeMode.light)}',
              ),
              AlertDialogAction<ThemeMode>(
                key: ThemeMode.dark,
                label: '${themeModeToString(ThemeMode.dark)}',
              ),
            ],
          );

          if (selectedTheme != null) {
            themeMode.state = selectedTheme;
          }
        },
      );
}

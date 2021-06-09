import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/home/temperature_tile.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> launchUrl(String url) async {
  if (await canLaunch(url)) {
    return await launch(url);
  } else {
    print('nope');
    return false;
  }
}

void showAppDetailsDialog(BuildContext context, PackageInfo packageInfo) {
  return showAboutDialog(
    context: context,
    applicationName: '${packageInfo.appName}',
    applicationVersion: '${packageInfo.version}',
    applicationLegalese: 'Made by Thomas Sterrenburg',
    children: <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyText2,
          children: <TextSpan>[
            TextSpan(
                text: 'FlutterHole is a free third party Android application '
                    'for interacting with your Pi-Hole® server. '
                    '\n\n'
                    'FlutterHole is open source, which means anyone '
                    'can view the code that runs your app. '
                    'You can find the repository on '),
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: KColors.link),
              text: 'GitHub',
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(KStrings.githubHomeUrl),
            ),
            TextSpan(
                text: '.'
                    '\n\n'
                    'Logo design by '),
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: KColors.link),
              text: 'Mathijs Sterrenburg',
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(KStrings.logoDesignerUrl),
            ),
            TextSpan(text: ', an amazing designer.'),
          ],
        ),
      ),
    ],
  );
}

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

String _temperatureReadingToString(TemperatureReading temperatureReading) {
  switch (temperatureReading) {
    case TemperatureReading.celcius:
      return 'Celcius (°C)';
    case TemperatureReading.fahrenheit:
      return 'Fahrenheit (°F)';
    case TemperatureReading.kelvin:
    default:
      return 'Kelvin (°K)';
  }
}

class VersionListTile extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final packageInfo = useProvider(packageInfoProvider);
    return ListTile(
      leading: Icon(KIcons.appVersion),
      title: Text('App version'),
      // subtitle: Text('${packageInfo.toString()}'),
      subtitle: packageInfo.when(
        data: (PackageInfo info) =>
            Text('${info.version} (build #${info.buildNumber})'),
        loading: () => Text(''),
        error: (o, s) => Text('No version information found'),
      ),
      onTap: packageInfo.maybeWhen(
          orElse: () => null,
          data: (info) => () => showAppDetailsDialog(context, info)),
    );
  }
}

class AppSettingsList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    final temperatureReading = useProvider(temperatureReadingProvider);
    final updateFrequency = useProvider(updateFrequencyProvider);

    final pi = useProvider(activePiProvider).state;

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
            buildThemeTile(themeMode),
            SettingsTile(
              title: 'Update frequency',
              subtitle: 'Every ${updateFrequency.state.inSeconds} seconds',
              leading: Icon(KIcons.updateFrequency),
              onPressed: (context) =>
                  showUpdateFrequencyDialog(context, context.read),
            ),
            SettingsTile(
              title: 'Temperature reading',
              subtitle:
                  '${_temperatureReadingToString(temperatureReading.state)}',
              leading: Icon(KIcons.temperatureReading),
              onPressed: (context) =>
                  showTemperatureReadingDialog(context, context.read),
            ),
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
        CustomSection(
          child: Column(
            children: [
              VersionListTile(),
              ListTile(
                subtitle: Text('${pi.baseApiUrl}'),
              ),
              ListTile(
                title: Text('$piSummary'),
                trailing: TextButton(
                    onPressed: () {
                      context.refresh(piSummaryProvider(pi));
                    },
                    child: Text('Fetch')),
              ),
            ],
          ),
        ),
        CustomSection(
          child: ListTile(
            subtitle: Text(pi.toString()),
          ),
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

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';
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
                  .bodyText2
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
                  .bodyText2
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

String temperatureReadingToString(TemperatureReading temperatureReading) {
  switch (temperatureReading) {
    case TemperatureReading.celcius:
      return 'Celcius (°C)';
    case TemperatureReading.fahrenheit:
      return 'Fahrenheit (°F)';
    case TemperatureReading.celciusAndFahrenheit:
    default:
      return 'Celcius & fahrenheit (°C/°F)';
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
      onTap: () {
        print('hi');
      },
      // onTap: packageInfo.maybeWhen(
      //     orElse: () => null,
      //     data: (info) => () => showAppDetailsDialog(context, info)),
    );
  }
}

class AppSettingsList extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    final temperatureReading = useProvider(temperatureReadingProvider);

    final pi = useProvider(activePiProvider);

    final summary = useProvider(summaryProvider);
    return SettingsList(
      sections: [
        CustomSection(child: SizedBox(height: 20.0)),
        CustomSection(
          child: SettingsTile(
            title: 'Active Pi-hole',
            subtitle: '${pi.state.title}',
            leading: Icon(KIcons.pihole),
            onPressed: (context) async {
              await showActivePiDialog(context, context.read);
              return;
              final selectedPi = await showConfirmationDialog(
                context: context,
                title: 'Active Pi-hole',
                initialSelectedActionKey: pi.state,
                actions: debugPis.map<AlertDialogAction<Pi>>((dPi) {
                  return AlertDialogAction<Pi>(
                    key: dPi,
                    label: '${dPi.title}',
                  );
                }).toList(),
              );

              if (selectedPi != null) {
                pi.state = selectedPi;
              }
            },
          ),
        ),
        SettingsSection(
          title: 'Customization',
          tiles: [
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
            ),
            SettingsTile(
              title: 'Temperature reading',
              subtitle:
                  '${temperatureReadingToString(temperatureReading.state)}',
              leading: Icon(KIcons.temperatureReading),
              onPressed: (context) async {
                final selectedTemperatureReading = await showConfirmationDialog(
                  context: context,
                  title: 'Temperature reading',
                  message: 'Used for the Pi-hole CPU temperature',
                  initialSelectedActionKey: temperatureReading.state,
                  actions: [
                    AlertDialogAction<TemperatureReading>(
                      key: TemperatureReading.celcius,
                      label:
                          '${temperatureReadingToString(TemperatureReading.celcius)}',
                    ),
                    AlertDialogAction<TemperatureReading>(
                      key: TemperatureReading.fahrenheit,
                      label:
                          '${temperatureReadingToString(TemperatureReading.fahrenheit)}',
                    ),
                    AlertDialogAction<TemperatureReading>(
                      key: TemperatureReading.celciusAndFahrenheit,
                      label:
                          '${temperatureReadingToString(TemperatureReading.celciusAndFahrenheit)}',
                    ),
                  ],
                );

                if (selectedTemperatureReading != null) {
                  temperatureReading.state = selectedTemperatureReading;
                }
              },
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
                subtitle: Text('${pi.state.baseApiUrl}'),
              ),
              ListTile(
                title: Text('$summary'),
                trailing: FlatButton(
                    onPressed: () {
                      context.refresh(summaryProvider);
                    },
                    child: Text('Fetch')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

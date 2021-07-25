import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/layout/buttons.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserPreferencesListView extends StatelessWidget {
  const UserPreferencesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _ThemeModeTile(),
          _TemperatureReadingTile(),
          _UpdateFrequencyTile(),
        ]);
  }
}

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
        leading: const Icon(KIcons.theme),
        title: const Text('Theme mode'),
        trailing: IconDropDownButtonBuilder<ThemeMode>(
          value: themeMode,
          onChanged: (update) {
            context
                .read(settingsNotifierProvider.notifier)
                .saveThemeMode(update);
          },
          values: ThemeMode.values,
          icons: const [
            KIcons.systemTheme,
            KIcons.lightTheme,
            KIcons.darkTheme,
          ],
          builder: (context, theme) => Text(_themeModeToString(theme)),
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
      title: const Text('Update frequency'),
      leading: const Icon(KIcons.updateFrequency),
      trailing: TextButton(
        child: Text(duration.inSeconds.secondsOrElse('Disabled')),
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

class _TemperatureReadingTile extends HookWidget {
  const _TemperatureReadingTile({
    Key? key,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    return ListTile(
      title: const Text('Temperature'),
      leading: const Icon(KIcons.temperatureReading),
      trailing: DropdownButton<TemperatureReading>(
          value: settings.userPreferences.temperatureReading,
          onChanged: (update) {
            if (update != null) {
              context
                  .read(settingsNotifierProvider.notifier)
                  .saveTemperatureReading(update);
            }
          },
          items: TemperatureReading.values
              .map<DropdownMenuItem<TemperatureReading>>(
                  (e) => DropdownMenuItem(
                        child: Text(_temperatureReadingToString(e)),
                        value: e,
                      ))
              .toList()),
    );
  }
}

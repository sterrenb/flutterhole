import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/layout/buttons.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeveloperPreferencesListView extends StatelessWidget {
  const DeveloperPreferencesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _UseThemeToggleButtonTile(),
        _UseAggressiveFetchingButtonTile(),
        _LogLevelTile(),
        _PreferencesCodeCard(),
      ].expand((element) => [element, SizedBox(height: 16.0)]).toList(),
    );
  }
}

class _PreferencesCodeCard extends HookWidget {
  const _PreferencesCodeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userPrefs = useProvider(userPreferencesProvider);
    final devPrefs = useProvider(developerPreferencesProvider);

    final map = {
      'preferences': {
        'user': userPrefs.toReadableMap(),
        'developer': devPrefs.toReadableMap(),
      }
    };
    return SelectableCodeCard(map.toJsonString());
  }
}

class _UseThemeToggleButtonTile extends HookWidget {
  const _UseThemeToggleButtonTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final x = useProvider(developerPreferencesProvider);
    return CheckboxListTile(
        title: Text('Use theme toggle'),
        subtitle: Text('Shows a theme toggle on most pages.'),
        secondary: Icon(KIcons.toggle),
        value: x.useThemeToggle,
        onChanged: (value) => context
            .read(settingsNotifierProvider.notifier)
            .toggleUseThemeToggle());
  }
}

class _UseAggressiveFetchingButtonTile extends HookWidget {
  const _UseAggressiveFetchingButtonTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final x = useProvider(useAggressiveFetchingProvider);
    return Column(
      children: [
        CheckboxListTile(
            title: Text('Use aggressive fetching'),
            subtitle: Text(
                'Disables the ${kRefreshDuration.inMilliseconds}ms delay between API calls during the dashboard refresh.'),
            secondary: Icon(KIcons.refresh),
            value: x,
            onChanged: (value) => context
                .read(settingsNotifierProvider.notifier)
                .toggleAggressiveFetching()),
      ],
    );
  }
}

extension LogLevelX on LogLevel {
  String get readable {
    switch (this) {
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
    }
  }
}

class _LogLevelTile extends HookWidget {
  const _LogLevelTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(logLevelProvider);
    return Center(
      child: ListTile(
        leading: Icon(KIcons.debugLogs),
        title: Text('Log level'),
        trailing: IconDropDownButtonBuilder<LogLevel>(
          value: themeMode,
          onChanged: (update) {
            context
                .read(settingsNotifierProvider.notifier)
                .saveLogLevel(update);
          },
          values: LogLevel.values,
          icons: [
            KIcons.debugLogs,
            KIcons.info,
            KIcons.logWarning,
            KIcons.logError,
          ],
          builder: (context, level) {
            return Text(level.readable);
          },
        ),
      ),
    );
  }
}

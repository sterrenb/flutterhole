import 'dart:math' as math;

import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final faker = Faker();
final random = math.Random();

class DevOnlyBuilder extends HookWidget {
  const DevOnlyBuilder({
    Key? key,
    required this.child,
    this.orElse,
  }) : super(key: key);

  final Widget child;
  final Widget? orElse;

  @override
  Widget build(BuildContext context) {
    final devMode = useProvider(devModeProvider);

    return devMode ? child : orElse ?? Container();
  }
}

class ThemeModeToggle extends HookWidget {
  const ThemeModeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dev = useProvider(developerPreferencesProvider);

    return dev.useThemeToggle == false ? Container() : _ThemeModeToggle();
  }
}

class _ThemeModeToggle extends HookWidget {
  const _ThemeModeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeMode = useProvider(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final VoidCallback onChanged = () {
      final update = isDark ? ThemeMode.light : ThemeMode.dark;
      context.read(settingsNotifierProvider.notifier).saveThemeMode(update);
    };

    return Tooltip(
      message: 'Toggle theme mode',
      child: Row(
        children: [
          IconButton(
            icon: Icon(KIcons.theme),
            onPressed: onChanged,
            visualDensity: VisualDensity.compact,
          ),
          Switch(
            value: isDark,
            onChanged: (_) {
              onChanged();
            },
            // icon: Icon(KIcons.systemTheme),
          ),
        ],
      ),
    );
  }
}

LogCall fakeLogCall() => LogCall(
      source: 'dev',
      level: (double v) {
        for (int index = 0; index < LogLevel.values.length; index++) {
          if (v <= index / LogLevel.values.length)
            return LogLevel.values.elementAt(index);
        }
        return LogLevel.debug;
      }(
        random.nextDouble(),
      ),
      message: faker.lorem.sentences(random.nextInt(3) + 1).join('. '),
    );

class AddLogTextButton extends HookWidget {
  const AddLogTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DevOnlyBuilder(
        child: TextButton(
            onPressed: () {
              print('logging to logNotifierProvider');

              context.read(logNotifierProvider.notifier).log(fakeLogCall());
              // context.log(call);
              // context.read(logNotifierProvider.notifier).log(call);
            },
            child: Text('Add log')));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeModeToggle extends HookWidget {
  const ThemeModeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dev = useProvider(developerPreferencesProvider);

    return dev.useThemeToggle == false ? Container() : _ThemeModeToggle();
  }
}

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

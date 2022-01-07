import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DevWidget extends HookConsumerWidget {
  const DevWidget({
    required this.child,
    this.show,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final bool? show;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);
    return Visibility(
      visible: devMode,
      child: child,
    );
  }
}

class DevToolBar extends HookConsumerWidget {
  const DevToolBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DevWidget(
        child: Row(
      children: const [
        _DevThemeToggle(),
      ],
    ));
  }
}

class _DevThemeToggle extends HookConsumerWidget {
  const _DevThemeToggle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final showThemeToggle = ref.watch(showThemeToggleProvider);
    return DefaultAnimatedOpacity(
      show: showThemeToggle,
      child: Tooltip(
        message: 'Toggle theme',
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              right: 16.0,
              child: Icon(
                KIcons.theme,
                size: 10.0,
              ),
            ),
            const Positioned(
              left: 16.0,
              child: Icon(
                KIcons.themeDark,
                size: 10.0,
              ),
            ),
            Switch(
              value: themeMode == ThemeMode.light,
              onChanged: (value) {
                ref.updateThemeMode(context, themeMode,
                    value ? ThemeMode.light : ThemeMode.dark);
              },
            ),
          ],
        ),
      ),
    );
  }
}

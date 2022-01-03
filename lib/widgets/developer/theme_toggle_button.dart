import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/layout/centered_leading.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeToggleButton extends HookConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showThemeToggle = ref.watch(showThemeToggleProvider);

    return CheckboxListTile(
        title: const Text('Show theme toggle'),
        subtitle: const Text('Enables the theme toggle on most pages.'),
        secondary: const CenteredLeading(child: Icon(KIcons.toggle)),
        value: showThemeToggle,
        onChanged: (value) => ref
            .read(UserPreferencesNotifier.provider.notifier)
            .toggleShowThemeToggle());
  }
}

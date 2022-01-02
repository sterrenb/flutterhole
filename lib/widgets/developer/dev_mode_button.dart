import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DevModeButton extends HookConsumerWidget {
  const DevModeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);
    return SwitchListTile(
      value: devMode,
      onChanged: (_) {
        ref.read(UserPreferencesNotifier.provider.notifier).toggleDevMode();
      },
      title: const Text("Developer mode"),
      secondary: const Icon(KIcons.developerMode),
    );
  }
}

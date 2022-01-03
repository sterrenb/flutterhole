import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LogoIcon extends HookConsumerWidget {
  const LogoIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = useState(0);
    final devMode = ref.watch(devModeProvider);
    const max = 10;

    return InkWell(
      child: const Image(
        image: AssetImage('assets/logo/logo.png'),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (devMode) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You are already a developer.'),
          ));
          return;
        }

        count.value = count.value + 1;
        if (count.value >= max) {
          ref.read(UserPreferencesNotifier.provider.notifier).toggleDevMode();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You are now a developer!'),
          ));
        } else if (count.value >= max ~/ 2) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Tap ${max - count.value} more times..."),
          ));
        }
      },
    );
  }
}

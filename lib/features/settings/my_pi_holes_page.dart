import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/settings/pi_builders.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyPiHolesPage extends HookWidget {
  const MyPiHolesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = useProvider(settingsNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pi-holes'),
      ),
      body: Column(
        children: [
          HookBuilder(builder: (context) {
            return const PiListBuilder();
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    final x = settings.active.copyWith(
                      title: settings.active.title + '!',
                      id: DateTime.now().millisecondsSinceEpoch,
                    );
                    context.read(settingsNotifierProvider.notifier).savePi(x);
                  },
                  child: const Text('add')),
            ],
          ),
        ],
      ),
    );
  }
}

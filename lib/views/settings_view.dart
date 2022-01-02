import 'package:flutter/material.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(activePingProvider);
    return Scaffold(
      body: Center(child: Text("Hi $summary")),
    );
  }
}

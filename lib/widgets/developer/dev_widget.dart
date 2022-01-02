import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class DevWidget extends HookConsumerWidget {
  const DevWidget({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);
    return Visibility(
      visible: devMode,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ActivePiTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    return Text(pi.title);
  }
}

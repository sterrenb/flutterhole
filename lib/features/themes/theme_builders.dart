import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PiColorsBuilder extends HookWidget {
  const PiColorsBuilder({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final ValueWidgetBuilder<PiColorTheme> builder;
  final Widget? child;

  Brightness platformBrightness(BuildContext context) =>
      MediaQuery.of(context).platformBrightness;

  @override
  Widget build(BuildContext context) {
    final piColors =
        useProvider(piColorThemeProvider(platformBrightness(context)));
    return builder(context, piColors, child);
  }
}

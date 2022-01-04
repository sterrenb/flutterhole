import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BaseView extends HookConsumerWidget {
  const BaseView({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      return Banner(
          message: 'Demo',
          textDirection: TextDirection.ltr,
          location: BannerLocation.bottomStart,
          child: child);
    }

    return child;
  }
}

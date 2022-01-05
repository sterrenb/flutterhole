import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'buttons.dart';

void useAsyncEffect(
  FutureOr<dynamic> Function() effect,
  FutureOr<dynamic> Function() cleanup, [
  List<Object> keys = const [],
]) {
  useEffect(() {
    Future.microtask(effect);
    return () {
      if (cleanup != null) {
        Future.microtask(cleanup);
      }
    };
  }, keys);
}

class UnreadNotificationsBanner extends HookConsumerWidget {
  const UnreadNotificationsBanner({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> notifications = ref.read(notificationsUnReadProvider);
    useAsyncEffect(() {
      if (notifications.isEmpty) return;
      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        content: Text(notifications.join('\n')),
        leading: const Icon(Icons.info),
        actions: [
          const UrlOutlinedButton(
            url: 'https://www.google.com/search?q=pihole+https',
            text: 'Pi-hole https',
          ),
          TextButton(
              onPressed: () {
                ref
                    .read(UserPreferencesNotifier.provider.notifier)
                    .markNotificationsAsRead(notifications);
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Got it')),
        ],
      ));
    }, () {}, [notifications]);
    return child;
  }
}

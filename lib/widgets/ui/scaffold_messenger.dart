import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/onboarding/introduction_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void useAsyncEffect(
  FutureOr<dynamic> Function() effect,
  FutureOr<dynamic> Function() cleanup, [
  List<Object> keys = const [],
]) {
  useEffect(() {
    Future.microtask(effect);
    return () {
      Future.microtask(cleanup);
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
    final List<String> unread = ref.read(notificationsUnReadProvider);
    // final List<String> notifications = ['Hello', 'World'];

    useAsyncEffect(() {
      if (kIsWeb && unread.contains(kWelcomeNotification)) {
        showOnboardingDialog(context, barrierDismissible: false,
            onGetStarted: () {
          ref
              .read(UserPreferencesNotifier.provider.notifier)
              .markNotificationsAsRead([kWelcomeNotification]);
        });
      }
    }, () {}, [unread]);

    final openedBanner = useState(false);
    useAsyncEffect(() {
      if (openedBanner.value || unread.isEmpty) return;
      openedBanner.value = true;
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
        content: Text(unread.join('\n')),
        leading: const Icon(Icons.info),
        actions: [
          TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Hide')),
          TextButton(
              onPressed: () {
                ref
                    .read(UserPreferencesNotifier.provider.notifier)
                    .markNotificationsAsRead(unread);
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('Got it')),
        ],
      ));
    }, () {}, [unread]);
    return child;
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/views/onboarding_view.dart';

import 'onboarding_carousel.dart';

Future<void> showOnboardingDialog(
  BuildContext context, {
  bool barrierDismissible = true,
  VoidCallback? onGetStarted,
}) =>
    showModal(
        context: context,
        builder: (c) {
          return WillPopScope(
            onWillPop: () async => barrierDismissible,
            child: AlertDialog(
              backgroundColor: Colors.orange,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
              contentPadding: const EdgeInsets.symmetric(vertical: 24.0),
              content: SizedBox(
                width: 500,
                height: 500,
                child: OnboardingCarousel(
                  onGetStarted: (context) {
                    if (onGetStarted != null) onGetStarted();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        });

class ShowIntroductionListTile extends StatelessWidget {
  const ShowIntroductionListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Introduction'),
      trailing: const Icon(KIcons.openDialog),
      onTap: () {
        kIsWeb
            ? showOnboardingDialog(context)
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const OnboardingView()));
      },
    );
  }
}

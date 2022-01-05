import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/developer/dev_widget.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/onboarding/onboarding_carousel.dart';
import 'package:flutterhole/widgets/ui/double_back_to_close_app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardingView extends HookConsumerWidget {
  const OnboardingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? BackButton(color: Theme.of(context).appBarTheme.backgroundColor)
            : null,
        actions: [
          DevWidget(
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsView()));
                },
                icon: const Icon(KIcons.settings)),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: DoubleBackToCloseApp(
        child: MobileMaxWidth(child: OnboardingCarousel(
          onGetStarted: (BuildContext context) {
            Navigator.canPop(context)
                ? Navigator.of(context).pop()
                : Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const SettingsView()));
          },
        )),
      ),
    );
  }
}

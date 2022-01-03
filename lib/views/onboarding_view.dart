import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/onboarding/onboarding_carousel.dart';
import 'package:flutterhole/widgets/ui/double_back_to_close_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsView()));
              },
              icon: const Icon(KIcons.settings)),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: const DoubleBackToCloseApp(
        child: MobileMaxWidth(child: OnboardingCarousel()),
      ),
    );
  }
}

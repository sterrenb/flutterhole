import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
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
        // title: Text(
        //   'Onboarding',
        //   style: Theme.of(context).textTheme.headline6,
        // ),
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
      body: DoubleBackToCloseApp(
        child: OnboardingCarousel(),
      ),
    );
  }
}

class OnboardingCarousel extends HookConsumerWidget {
  const OnboardingCarousel({
    Key? key,
  }) : super(key: key);

  final bool isInitialPage = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();

    void animateToPage(int index) {
      pageController.animateToPage(
        index,
        curve: Curves.easeOutCubic,
        duration: kThemeAnimationDuration * 2,
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          scrollBehavior: _WebScrollBehavior(),
          controller: pageController,
          physics: const BouncingScrollPhysics(),
          children: [
            _ControlPage(),
            Container(color: Colors.green),
            Container(color: Colors.blueGrey),
            Container(color: Colors.purple),
            // _ControlPage(
            //     titleStyle: titleStyle, descriptionStyle: descriptionStyle),
            // _MonitorPage(titleStyle: titleStyle),
            // _DashboardPage(titleStyle: titleStyle),
            // _Page(
            //   leading: Image(
            //       // width: 24.0,
            //       image: AssetImage(
            //     Theme.of(context).brightness == Brightness.light
            //         ? 'assets/icons/github_dark.png'
            //         : 'assets/icons/github_light.png',
            //   )),
            //   title: Text.rich(
            //     TextSpan(
            //       text: '',
            //       style: Theme.of(context).textTheme.headline4,
            //       children: <TextSpan>[
            //         const TextSpan(text: 'Free and '),
            //         TextSpan(text: 'open-source', style: titleStyle),
            //         const TextSpan(text: '.'),
            //         // can add more TextSpans here...
            //       ],
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            //   description: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       // Text("Perform all the commands:"),
            //       Column(
            //         // mainAxisSize: MainAxisSize.min,
            //         // crossAxisAlignment: WrapCrossAlignment.center,
            //         children: [
            //           Text(
            //             'You can find the code and support this project on GitHub.',
            //             style: descriptionStyle,
            //             textAlign: TextAlign.center,
            //           ),
            //           const SizedBox(height: 16.0),
            //           CodeCard(
            //             code: KUrls.githubHomeUrl,
            //             onTap: () => launchUrl(KUrls.githubHomeUrl),
            //           ),
            //           // Text('GitHub', style: descriptionStyle),
            //         ],
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
        Positioned(
          bottom: 0,
          top: 100,
          child: Container(
            // color: Colors.white.withOpacity(.2),
            color: Colors.green,
          ),
        ),
        Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: isInitialPage,
                      child: OutlinedButton(
                        child: const Text('Skip '),
                        onPressed: () async {
                          if (kDebugMode) {
                            // context.router.replace(const HomeRoute());
                            // return;
                          }
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => SignInPage()));
                        },
                        // onPressed: () => ExtendedNavigator.of(context)
                        //     .pushSignInPage(
                        //         startingIndex: SignInStartingIndex.signUp),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: 4,
                        onDotClicked: animateToPage,
                        effect: WormEffect(
                          type: WormType.thin,
                          dotColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.2),
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                        // effect: ExpandingDotsEffect(
                        //   dotColor: Theme.of(context)
                        //       .colorScheme
                        //       .secondary
                        //       .withOpacity(.2),
                        //   activeDotColor:
                        //       Theme.of(context).colorScheme.secondary,
                        // ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Visibility(
                      visible: isInitialPage,
                      child: OutlinedButton(
                        child: const Text('Get started'),
                        onPressed: () {},
                        // onPressed: () => ExtendedNavigator.of(context)
                        //     .pushSignInPage(
                        //         startingIndex: SignInStartingIndex.signIn),
                        // onPressed: () => _animateToPage(0),
                      ),
                    ),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    Key? key,
    required this.leading,
    required this.title,
    required this.description,
  }) : super(key: key);

  final Widget leading;
  final Widget title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          Expanded(child: leading),
          const SizedBox(height: 60),
          title,
          const SizedBox(height: 20),
          description,
          const Spacer(),
        ],
      ),
    );
  }
}

class _ControlPage extends StatelessWidget {
  const _ControlPage({Key? key}) : super(key: key);

  // final TextStyle titleStyle;
  // final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = Theme.of(context).textTheme.headline5;
    final codeStyle = descriptionStyle?.merge(
        GoogleFonts.firaMono(color: Theme.of(context).colorScheme.primary));
    final titleStyle = Theme.of(context).textTheme.headline4?.copyWith(
          decoration: TextDecoration.underline,
          color: Theme.of(context).colorScheme.secondary,
        );
    return _Page(
      leading: Opacity(
        opacity: .8,
        child: Image(
          image: AssetImage(context.isLight
              ? 'assets/logo/logo_dark.png'
              : 'assets/logo/logo.png'),
          width: 200.0,
        ),
      ),
      title: Text.rich(
        TextSpan(
          text: '',
          style: Theme.of(context).textTheme.headline4,
          children: <TextSpan>[
            TextSpan(text: 'Control', style: titleStyle),
            const TextSpan(text: ' your Pi-hole.'),
            // can add more TextSpans here...
          ],
        ),
        textAlign: TextAlign.center,
      ),
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("Perform all the commands:"),
          Wrap(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Use commands like ', style: descriptionStyle),
              Text('enable', style: codeStyle),
              Text(', ', style: descriptionStyle),
              Text('disable', style: codeStyle),
              Text(' and ', style: descriptionStyle),
              Text('sleep', style: codeStyle),
              Text(' with ease.', style: descriptionStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

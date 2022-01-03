import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/views/settings_view.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/widgets/onboarding/demo_dashboard.dart';
import 'package:flutterhole/widgets/onboarding/demo_log_list.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:flutterhole/widgets/ui/images.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingCarousel extends HookConsumerWidget {
  const OnboardingCarousel({
    Key? key,
  }) : super(key: key);

  final bool isInitialPage = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final pagePosition = useState(0.0);
    useEffect(() {
      pageController.addListener(() {
        pagePosition.value = pageController.page ?? 0.0;
      });
    }, [pageController]);

    final descriptionStyle = Theme.of(context).textTheme.headline5;
    final codeStyle = descriptionStyle?.merge(
        GoogleFonts.firaMono(color: Theme.of(context).colorScheme.primary));
    final titleStyle = Theme.of(context).textTheme.headline4?.copyWith(
          decoration: TextDecoration.underline,
          color: Theme.of(context).colorScheme.secondary,
        );

    void animateToPage(int index) {
      pageController.animateToPage(
        index,
        curve: Curves.easeOutCubic,
        duration: kThemeAnimationDuration * 2,
      );
    }

    void animateToNextPage() {
      pageController.nextPage(
        curve: Curves.easeOutCubic,
        duration: kThemeAnimationDuration * 2,
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Center(
          child: Text(pagePosition.value < 2
              ? 'Go the other way!'
              : 'Time to get Started!'),
        ),
        PageView(
          scrollBehavior: _WebScrollBehavior(),
          controller: pageController,
          physics: const BouncingScrollPhysics(),
          children: [
            _Page(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text('Use commands like ', style: descriptionStyle),
                      Text('enable', style: codeStyle),
                      Text(', ', style: descriptionStyle),
                      Text('disable', style: codeStyle),
                      Text(' and ', style: descriptionStyle),
                      Text('sleep', style: codeStyle),
                      _TooltipDirect(
                        message:
                            '🔐 API token required for full functionality!',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(' with ease', style: descriptionStyle),
                            Text('*',
                                style: descriptionStyle?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                )),
                            Text('.', style: descriptionStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Page(
              leading: const SizedBox(
                  width: 500.0,
                  child: Opacity(
                      opacity: .8,
                      child: Center(child: AnimatedDemoLogList()))),
              title: Text.rich(
                TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.headline4,
                  children: <TextSpan>[
                    const TextSpan(text: ''),
                    TextSpan(text: 'Monitor', style: titleStyle),
                    const TextSpan(text: ' your network.'),
                    // can add more TextSpans here...
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              description: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Text('Inspect and triage all ', style: descriptionStyle),
                  _TooltipDirect(
                      message: '🗄️ Domain Name System',
                      child: Text('DNS', style: codeStyle)),
                  Text(' requests.', style: descriptionStyle),
                ],
              ),
            ),
            _Page(
              leading: const SizedBox(
                width: 300.0,
                child: Center(
                  child: Opacity(opacity: .8, child: DemoDashboard()),
                ),
              ),
              title: Text.rich(
                TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.headline4,
                  children: <TextSpan>[
                    TextSpan(text: 'Customize', style: titleStyle),
                    const TextSpan(text: ' your dashboard.'),
                    // can add more TextSpans here...
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              description: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'Select which information you want, in which order.',
                    style: descriptionStyle,
                  ),
                ],
              ),
            ),
            _Page(
              leading: const Card(
                  color: Color(0xfffefffe),
                  // color: Colors.green,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: GithubOctoImage(),
                  )),
              title: Text.rich(
                TextSpan(
                  text: '',
                  style: Theme.of(context).textTheme.headline4,
                  children: [
                    TextSpan(text: 'Free', style: titleStyle),
                    const TextSpan(text: ' and '),
                    const TextSpan(text: 'open source.'),
                    // can add more TextSpans here...
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              description: Column(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    children: [
                      Text('Want to support this app? ',
                          style: descriptionStyle),
                      Text('Check out the homepage on ',
                          style: descriptionStyle),
                      Text('GitHub', style: codeStyle),
                      Text('.', style: descriptionStyle),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const UrlOutlinedButton(
                    url: KUrls.githubHomeUrl,
                    text: 'FlutterHole on GitHub',
                  ),
                ],
              ),
            ),
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
                          child: const Text('Next'),
                          onPressed: () {
                            animateToNextPage();
                          }
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
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const SettingsView()));
                        },
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        minimum: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),
            Expanded(child: AspectRatio(aspectRatio: 1.5, child: leading)),
            const SizedBox(height: 50),
            title,
            const SizedBox(height: 20),
            description,
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _TooltipDirect extends StatelessWidget {
  const _TooltipDirect({
    Key? key,
    required this.message,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: message,
      child: child,
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

import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/layout/double_back_to_close_app.dart';
import 'package:flutterhole_web/features/layout/list.dart';
import 'package:flutterhole_web/features/routing/app_router.gr.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends HookWidget {
  const OnboardingPage({
    Key? key,
    this.isInitialPage = true,
  }) : super(key: key);

  // If false, the buttons will pop instead of replace.
  final bool isInitialPage;

  @override
  Widget build(BuildContext context) {
    print('isInitialPage: $isInitialPage');

    final pageController = usePageController();

    void _animateToPage(int index) {
      pageController.animateToPage(
        index,
        curve: Curves.easeOutCubic,
        duration: kThemeAnimationDuration * 2,
      );
    }

    final titleStyle = TextStyle(
      decoration: TextDecoration.underline,
      color: Theme.of(context).colorScheme.secondary,
    );

    final descriptionStyle = Theme.of(context).textTheme.headline5;

    final prefs = useProvider(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: [
          Text('${prefs.firstUse}: ${prefs.lastStartup}'),
          ThemeModeToggle(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: DoubleBackToCloseApp(
          enabled: isInitialPage,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _ControlPage(
                      titleStyle: titleStyle,
                      descriptionStyle: descriptionStyle),
                  _MonitorPage(titleStyle: titleStyle),
                  _DashboardPage(titleStyle: titleStyle),
                  _Page(
                    leading: Image(
                        // width: 24.0,
                        image: AssetImage(
                      Theme.of(context).brightness == Brightness.light
                          ? 'assets/icons/github_dark.png'
                          : 'assets/icons/github_light.png',
                    )),
                    title: Text.rich(
                      TextSpan(
                        text: "",
                        style: Theme.of(context).textTheme.headline4,
                        children: <TextSpan>[
                          TextSpan(text: "Free and "),
                          TextSpan(text: "open-source", style: titleStyle),
                          TextSpan(text: "."),
                          // can add more TextSpans here...
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    description: Container(
                      // color: Colors.orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text("Perform all the commands:"),
                          Container(
                            // color: Colors.blueAccent,
                            child: Column(
                              // mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'You can find the code and support this project on GitHub.',
                                  style: descriptionStyle,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.0),
                                CodeCard(
                                  code: KUrls.githubHomeUrl,
                                  onTap: () => launchUrl(KUrls.githubHomeUrl),
                                ),
                                // Text('GitHub', style: descriptionStyle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
                            child: TextButton(
                              child: Text("Skip setup"),
                              onPressed: () async {
                                if (kDebugMode) {
                                  context.router.replace(HomeRoute());
                                  return;
                                }

                                await showModal(
                                    context: context,
                                    builder: (context) => ConfirmationDialog(
                                        title: 'Skip setup?',
                                        onConfirm: () {
                                          context.router.replace(HomeRoute());
                                        },
                                        body: Text(
                                            'If you already know your Pi-hole information, you can directly go to the dashboard.\n\nFor full functionality, add your API token in the Pi-hole settings.')));

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
                              onDotClicked: _animateToPage,
                              effect: ExpandingDotsEffect(
                                dotColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(.2),
                                activeDotColor:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Visibility(
                            visible: isInitialPage,
                            child: TextButton(
                              child: Text("Get started"),
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
          )),
    );
  }
}

class _MonitorPage extends StatelessWidget {
  const _MonitorPage({
    Key? key,
    required this.titleStyle,
  }) : super(key: key);

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return _Page(
      leading: Container(
          width: 300.0,
          // color: Colors.purple.withOpacity(.2),
          child: Card(
              elevation: 0.0,
              child: Opacity(
                  opacity: .8, child: Center(child: _AnimatedDemoLogList())))),
      title: Text.rich(
        TextSpan(
          text: "",
          style: Theme.of(context).textTheme.headline4,
          children: <TextSpan>[
            TextSpan(text: "Easily "),
            TextSpan(text: "monitor", style: titleStyle),
            TextSpan(text: " your network."),
            // can add more TextSpans here...
          ],
        ),
        textAlign: TextAlign.center,
      ),
      description: _PageDescription("Inspect and triage all DNS requests."),
    );
  }
}

class _ControlPage extends StatelessWidget {
  const _ControlPage({
    Key? key,
    required this.titleStyle,
    required this.descriptionStyle,
  }) : super(key: key);

  final TextStyle titleStyle;
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    return _Page(
      leading: Opacity(
        opacity: .8,
        child: Image(
          image: AssetImage(Theme.of(context).brightness == Brightness.light
              ? 'assets/icons/logo_dark.png'
              : 'assets/icons/logo.png'),
          width: 200.0,
        ),
      ),
      title: Text.rich(
        TextSpan(
          text: "",
          style: Theme.of(context).textTheme.headline4,
          children: <TextSpan>[
            TextSpan(text: "Control", style: titleStyle),
            TextSpan(text: " your Pi-hole."),
            // can add more TextSpans here...
          ],
        ),
        textAlign: TextAlign.center,
      ),
      description: Container(
        // color: Colors.orange,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text("Perform all the commands:"),
            Container(
              // color: Colors.blueAccent,
              child: Wrap(
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Use commands like ', style: descriptionStyle),
                  CodeCard(code: 'enable'),
                  Text(', ', style: descriptionStyle),
                  CodeCard(code: 'disable'),
                  Text(' and ', style: descriptionStyle),
                  CodeCard(code: 'sleep'),
                  Text(' with ease.', style: descriptionStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage({
    Key? key,
    required this.titleStyle,
  }) : super(key: key);

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return _Page(
      leading: Container(
        width: 300.0,
        child: Center(
          child: StaggeredGridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: kGridSpacing,
            crossAxisSpacing: kGridSpacing,
            padding: const EdgeInsets.all(kGridSpacing),
            physics: NeverScrollableScrollPhysics(),
            staggeredTiles: [
              StaggeredTile.count(3, 1),
              StaggeredTile.count(1, 2),
              StaggeredTile.count(2, 1),
              StaggeredTile.count(1, 1),
            ],
            children: [
              _ColorCard(duration: Duration(seconds: 2)),
              _ColorCard(duration: Duration(seconds: 3)),
              _ColorCard(duration: Duration(seconds: 4)),
              _ColorCard(duration: Duration(seconds: 5)),
            ],
          ),
        ),
      ),
      title: Text.rich(
        TextSpan(
          text: "",
          style: Theme.of(context).textTheme.headline4,
          children: <TextSpan>[
            TextSpan(text: "Customize", style: titleStyle),
            TextSpan(text: " your dashboard."),
            // can add more TextSpans here...
          ],
        ),
        textAlign: TextAlign.center,
      ),
      description: _PageDescription(
          "Select which information you want, in which order."),
    );
  }
}

class _AnimatedDemoLogList extends HookWidget {
  const _AnimatedDemoLogList({
    Key? key,
  }) : super(key: key);

  static final Duration duration = kThemeAnimationDuration * 3;

  @override
  Widget build(BuildContext context) {
    final list = useState([20, 50, 100]);
    final k = useState(GlobalKey<AnimatedListState>()).value;

    void deleteAtIndex(int index) {
      final id = list.value.elementAt(index);
      list.value = [...list.value..removeAt(index)];
      k.currentState?.removeItem(
          index, (context, animation) => _DemoLogTile(id, animation),
          duration: duration);

      list.value = [
        Random().nextInt(80) + 30,
        ...list.value,
      ];
      k.currentState?.insertItem(0, duration: duration);
    }

    useEffect(() {
      final timer = Timer.periodic(Duration(seconds: 2), (timer) {
        deleteAtIndex(list.value.length - 1);
      });

      return timer.cancel;
    }, const []);

    return AnimatedList(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      key: k,
      initialItemCount: list.value.length,
      itemBuilder: (context, index, animation) {
        return InkWell(
            // onTap: () {
            // deleteAtIndex(index);
            // },
            child: _DemoLogTile(list.value.elementAt(index), animation));
      },
    );
  }
}

class _DemoLogTile extends HookWidget {
  const _DemoLogTile(
    this.id,
    this.animation, {
    Key? key,
  }) : super(key: key);

  final int id;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedListTile(
      animation: animation,
      child: ListTile(
        // leading: Text(id.toString()),
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.onSurface,
                  child: Container(
                    height: Theme.of(context).textTheme.headline6!.fontSize,
                    width: constraints.maxWidth * (id / 120),
                  ),
                ),
              ],
            );
          },
        ),
        subtitle: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.onSurface,
                  child: Container(
                    height: Theme.of(context).textTheme.bodyText2!.fontSize,
                    width: constraints.maxWidth * ((id / 200) + .4),
                  ),
                ),
              ],
            );
          },
        ),
        // subtitle: Row(
        //   children: [
        //     Flexible(
        //       flex: 10,
        //       child: Container(
        //         height: Theme.of(context).textTheme.bodyText2!.fontSize,
        //         color: Theme.of(context).colorScheme.onSurface,
        //       ),
        //     ),
        //     Flexible(
        //       // flex: random.value.nextInt(10),
        //       flex: 5,
        //       child: Container(),
        //     ),
        //   ],
        // ),
      ),
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
      minimum: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Spacer(),
          Expanded(child: leading),
          SizedBox(height: 60),
          title,
          SizedBox(height: 20),
          description,
          Spacer(),
        ],
      ),
    );
  }
}

class _PageDescription extends StatelessWidget {
  const _PageDescription(
    this.description, {
    Key? key,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).textTheme.headline5,
      textAlign: TextAlign.center,
    );
  }
}

final _random = Random();

class _ColorCard extends HookWidget {
  const _ColorCard({
    Key? key,
    required this.duration,
    this.initialColor,
  }) : super(key: key);

  final Duration duration;
  final Color? initialColor;

  @override
  Widget build(BuildContext context) {
    Color randomColor() =>
        Colors.primaries.elementAt(_random.nextInt(Colors.primaries.length));

    final color = useState(initialColor ?? randomColor());

    useEffect(() {
      final timer = Timer.periodic(duration, (timer) {
        color.value = randomColor();
      });

      return timer.cancel;
    }, const []);

    return GridCard(
      child: AnimatedContainer(
        duration: kThemeAnimationDuration * 5,
        curve: Curves.ease,
        color: color.value,
      ),
    );
  }
}

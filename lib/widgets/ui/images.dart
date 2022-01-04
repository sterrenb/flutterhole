import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LogoImage extends HookConsumerWidget {
  const LogoImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = useState(0);
    final devMode = ref.watch(devModeProvider);
    const max = 10;

    return InkWell(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Opacity(
          opacity: .8,
          child: Image(
            image: AssetImage(context.isLight
                ? 'assets/logo/logo_dark.png'
                : 'assets/logo/logo.png'),
          ),
        ),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (devMode) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You are already a developer.'),
          ));
          return;
        }

        count.value = count.value + 1;
        if (count.value >= max) {
          ref.read(UserPreferencesNotifier.provider.notifier).toggleDevMode();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You are now a developer!'),
          ));
        } else if (count.value >= max ~/ 2) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Tap ${max - count.value} more times..."),
          ));
        }
      },
    );
  }
}

class GithubImage extends StatelessWidget {
  const GithubImage({Key? key, this.width, this.height}) : super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: context.isLight ? 1.0 : 0.8,
      child: Image(
          width: width,
          height: height,
          image: AssetImage(
            context.isLight
                ? 'assets/images/github_dark.png'
                : 'assets/images/github_light.png',
          )),
    );
  }
}

class GithubOctoImage extends StatelessWidget {
  const GithubOctoImage({Key? key, this.width, this.height}) : super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image(
        width: width,
        height: height,
        image: const AssetImage('assets/images/octocat.jpg'));
  }
}

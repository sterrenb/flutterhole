import 'package:flutter/material.dart';
import 'package:flutterhole/widgets/layout/responsiveness.dart';

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

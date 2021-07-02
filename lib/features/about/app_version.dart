import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

void showAppDetailsDialog(BuildContext context, PackageInfo packageInfo) {
  return showAboutDialog(
    context: context,
    applicationName: packageInfo.appName,
    applicationVersion: packageInfo.version,
    applicationLegalese: 'Made by Thomas Sterrenburg',
    children: <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyText2,
          children: <TextSpan>[
            const TextSpan(
                text: 'FlutterHole is a free third party application '
                    'for interacting with your Pi-Hole® server. '
                    '\n\n'
                    'FlutterHole is open source, which means anyone '
                    'can view the code that runs your app. '
                    'You can find the repository on '),
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: KColors.link),
              text: 'GitHub',
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(KUrls.githubHomeUrl),
            ),
            const TextSpan(
                text: '.'
                    '\n\n'
                    'Logo design by '),
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .apply(color: KColors.link),
              text: 'Mathijs Sterrenburg',
              recognizer: TapGestureRecognizer()
                ..onTap = () => launchUrl(KUrls.logoDesignerUrl),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    ],
  );
}

class PackageVersionText extends HookWidget {
  const PackageVersionText({
    Key? key,
    this.includeBuild = true,
    this.textStyle,
  }) : super(key: key);

  final bool includeBuild;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final packageInfo = useProvider(packageInfoProvider);
    return packageInfo.when(
      data: (PackageInfo info) => Text(
        'v${info.version}' +
            (includeBuild ? ' (build #${info.buildNumber})' : ''),
        style: textStyle,
      ),
      loading: () => Text(
        '',
        style: textStyle,
      ),
      error: (o, s) => Text(
        'No version information found',
        style: textStyle,
      ),
    );
  }
}

class AppVersionListTile extends HookWidget {
  const AppVersionListTile({
    Key? key,
    this.title = 'App version',
    this.showLicences = true,
  }) : super(key: key);

  final String title;
  final bool showLicences;

  @override
  Widget build(BuildContext context) {
    final packageInfo = useProvider(packageInfoProvider);
    return ListTile(
      leading: const Icon(KIcons.appVersion),
      title: Text(title),
      // subtitle: Text('${packageInfo.toString()}'),
      subtitle: const PackageVersionText(),
      trailing: showLicences
          ? TextButton(
              onPressed: packageInfo.maybeWhen(
                data: (info) => () => showAppDetailsDialog(context, info),
                orElse: () => null,
              ),
              child: Text(
                'Licences'.toUpperCase(),
                style: TextStyle(color: Theme.of(context).accentColor),
              ))
          : null,
    );
  }
}

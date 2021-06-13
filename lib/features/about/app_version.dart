import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

void showAppDetailsDialog(BuildContext context, PackageInfo packageInfo) {
  return showAboutDialog(
    context: context,
    applicationName: '${packageInfo.appName}',
    applicationVersion: '${packageInfo.version}',
    applicationLegalese: 'Made by Thomas Sterrenburg',
    children: <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyText2,
          children: <TextSpan>[
            TextSpan(
                text: 'FlutterHole is a free third party Android application '
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
            TextSpan(
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
            TextSpan(text: '.'),
          ],
        ),
      ),
    ],
  );
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
      leading: Icon(KIcons.appVersion),
      title: Text(title),
      // subtitle: Text('${packageInfo.toString()}'),
      subtitle: packageInfo.when(
        data: (PackageInfo info) =>
            Text('${info.version} (build #${info.buildNumber})'),
        loading: () => Text(''),
        error: (o, s) => Text('No version information found'),
      ),
      trailing: showLicences
          ? TextButton(
              onPressed: packageInfo.maybeWhen(
                  orElse: () => null,
                  data: (info) => () => showAppDetailsDialog(context, info)),
              child: Text('Licences'))
          : null,
    );
  }
}

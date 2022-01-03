import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final _packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

class AppVersionListTile extends HookConsumerWidget {
  const AppVersionListTile({
    Key? key,
    this.title = 'App version',
    this.showLicences = true,
  }) : super(key: key);

  final String title;
  final bool showLicences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(_packageInfoProvider);
    return ListTile(
      leading: const Icon(KIcons.appVersion),
      title: Text(title),
      // subtitle: Text('${packageInfo.toString()}'),
      subtitle: const PackageVersionText(),
      trailing: showLicences
          ? OutlinedButton(
              onPressed: packageInfo.maybeWhen(
                data: (info) => () => showAppDetailsDialog(context, info),
                orElse: () => null,
              ),
              child: const Text('Licences'))
          : null,
    );
  }
}

void showAppDetailsDialog(BuildContext context, PackageInfo packageInfo) {
  return showAboutDialog(
    context: context,
    applicationName: packageInfo.appName,
    applicationVersion: packageInfo.version,
    applicationLegalese: 'Made by tster.nl',
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
                  .copyWith(color: Theme.of(context).colorScheme.primary),

              // .apply(color: KColors.link),
              text: 'GitHub',
              recognizer: TapGestureRecognizer()
                ..onTap =
                    () => WebService.launchUrlInBrowser(KUrls.githubHomeUrl),
            ),
            const TextSpan(
                text: '.'
                    '\n\n'
                    'Logo design by '),
            TextSpan(
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              // .apply(color: KColors.link),
              text: 'Mathijs Sterrenburg',
              recognizer: TapGestureRecognizer()
                ..onTap =
                    () => WebService.launchUrlInBrowser(KUrls.logoDesignerUrl),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    ],
  );
}

class PackageVersionText extends HookConsumerWidget {
  const PackageVersionText({
    Key? key,
    this.includeBuild = true,
    this.textStyle,
  }) : super(key: key);

  final bool includeBuild;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(_packageInfoProvider);
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

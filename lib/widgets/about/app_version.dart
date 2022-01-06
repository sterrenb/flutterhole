import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants/icons.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/layout/grids.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/buttons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionListTile extends HookConsumerWidget {
  const AppVersionListTile({
    Key? key,
    this.title = 'App version',
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    return ListTile(
      leading: const Icon(KIcons.appVersion),
      title: Text(title),
      subtitle: packageInfo.when(
        data: (PackageInfo info) => Text(
          Formatting.packageInfoToString(info),
          style: GoogleFonts.firaMono(),
        ),
        loading: () => const Text(''),
        error: (o, s) => Text(o.toString()),
      ),
      trailing: OutlinedButton(
          onPressed: packageInfo.maybeWhen(
            data: (info) => () => showAppDetailsDialog(context, info),
            orElse: () => null,
          ),
          child: const Text('Licences')),
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

class PackageInfoBuilder extends HookConsumerWidget {
  const PackageInfoBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ValueWidgetBuilder<PackageInfo?> builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    return packageInfo.when(
      data: (PackageInfo info) => Text(
        Formatting.packageInfoToString(info),
        style: GoogleFonts.firaMono(),
      ),
      loading: () => const Text(
        '',
      ),
      error: (o, s) => const Text(
        'No version information found',
      ),
    );
  }
}

class SubmitBugReportListTile extends HookConsumerWidget {
  const SubmitBugReportListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);

    return ListTile(
      leading: const Icon(KIcons.bugReport),
      title: const Text('Submit a bug report'),
      trailing: const Icon(KIcons.openUrl),
      onTap: () {
        ref.submitGithubIssue(
            title: packageInfo.whenOrNull(
          data: (PackageInfo info) =>
              Formatting.packageInfoToString(info, false),
        ));
      },
    );
  }
}

class SubmitFeatureRequestListTile extends HookConsumerWidget {
  const SubmitFeatureRequestListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);

    return ListTile(
      leading: const Icon(KIcons.featureRequest),
      title: const Text('Request a feature'),
      trailing: const Icon(KIcons.openUrl),
      onTap: () {
        ref.submitGithubIssue(
            feature: true,
            title: packageInfo.whenOrNull(
              data: (PackageInfo info) =>
                  Formatting.packageInfoToString(info, false),
            ));
      },
    );
  }
}

class RedditSupportListTile extends HookConsumerWidget {
  const RedditSupportListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);

    return ListTile(
      leading: const Icon(KIcons.community),
      title: Row(
        children: [
          const Text('Ask the '),
          Text(
            '/r/pihole/',
            style: GoogleFonts.firaMono(),
          ),
          const Text(' community')
          // const Text(' on Reddit'),
        ],
      ),
      trailing: const Icon(KIcons.openUrl),
      onTap: () {
        ref.submitRedditPost(
            'FlutterHole',
            packageInfo.whenOrNull(
                  data: (PackageInfo info) =>
                      'Hello, %0D%0A%0D%0AI am using [FlutterHole](${KUrls.githubHomeUrl}) ${Formatting.packageInfoToString(info, false)}.',
                ) ??
                '');
      },
    );
  }
}

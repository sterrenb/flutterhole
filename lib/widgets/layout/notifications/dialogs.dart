import 'package:alice/alice.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/widgets/layout/notifications/copy_button.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';
import 'package:package_info/package_info.dart';

Future<void> showWelcomeDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('FlutterHole V5'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                  'Thank you for trying out FlutterHole, a third party Android application for the Pi-Hole® dashboard.\n'),
              Text(
                  'To make full use of this app, you need to enter an API token. You can find this in the dashboard of your Pi-hole. Check Settings > My Pi-holes to enter your token.\n'),
              Text(
                  'Note: some users experience issues when upgrading from version 2.x. Re-installing the app after clearing the cache works for some people.\n'),
              Text(
                  'If you have any issues, please report them on GitHub. Other users can share their own issues and solutions here.')
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Got it!'),
          ),
        ],
      );
    },
  );
}

Future<bool> showConfirmationDialog(
  BuildContext context, {
  Widget title,
}) async {
  final result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: title ?? Text('Confirm'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            OutlineButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      });

  return result ?? false;
}

Future<void> showFailureDialog(
  BuildContext context,
  Failure failure, {
  Widget title,
}) async {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('${failure?.message ?? 'unknown failure'}'),
              Text('${failure?.error?.toString() ?? ''}'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton.icon(
            label: Text('API Log'),
            icon: Icon(KIcons.apiLog),
            onPressed: () {
              getIt<Alice>().showInspector();
            },
          ),
          CopyFlatButton(
            '${failure.toJson()}',
            onCopy: () {
              Navigator.of(dialogContext).pop();
              showInfoSnackBar(context, 'Copied failure to clipboard');
            },
          ),
        ],
      );
    },
  );
}

void showAppDetailsDialog(BuildContext context, PackageInfo packageInfo) {
  return showAboutDialog(
    context: context,
    applicationName: '${packageInfo.appName}',
    applicationVersion: '${packageInfo.version}',
    applicationLegalese: 'Made by Sterrenburg',
    children: <Widget>[
      SizedBox(height: 24),
      RichText(
        text: TextSpan(
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
                  .bodyText2
                  .apply(color: KColors.link),
              text: 'GitHub',
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    getIt<BrowserService>().launchUrl(KStrings.githubHomeUrl),
            ),
            TextSpan(
                text: '.'
                    '\n\n'
                    'Logo design by '),
            TextSpan(
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyText2
                  .apply(color: KColors.link),
              text: 'Mathijs Sterrenburg',
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    getIt<BrowserService>().launchUrl(KStrings.logoDesignerUrl),
            ),
            TextSpan(text: ', an amazing designer.'),
          ],
        ),
      ),
    ],
  );
}

class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
//        width: 200,
//        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage('assets/icon/icon.png'),
              fit: BoxFit.cover,
            )),
      ),
    );
  }
}

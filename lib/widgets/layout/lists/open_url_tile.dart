import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';

class OpenUrlTile extends StatelessWidget {
  const OpenUrlTile({
    Key key,
    @required this.url,
    this.leading,
    this.title,
  }) : super(key: key);

  final String url;
  final Widget leading;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open $url',
      child: ListTile(
        onTap: () async {
          final didLaunch = await getIt<BrowserService>().launchUrl(url);
          if (!didLaunch) {
            showErrorSnackBar(context, 'Could not open $url');
          }
        },
        leading: leading,
        title: title,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/widgets/layout/snackbars.dart';

const String _numbersApiHome = 'http://numbersapi.com/';

class NumbersApiDescriptionTile extends StatelessWidget {
  const NumbersApiDescriptionTile({
    Key key,
    @required this.integer,
  }) : super(key: key);

  final int integer;

  String get url => '$_numbersApiHome#$integer';

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
        leading: Icon(KIcons.info),
        title: Row(
          children: <Widget>[
            Text('Powered by the '),
            Text(
              'Numbers API',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:flutterhole/widgets/layout/animate_on_build.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({
    Key key,
    @required this.privacyReadmeTextFuture,
  }) : super(key: key);

  final Future<String> privacyReadmeTextFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy'),
        actions: <Widget>[
          IconButton(
              tooltip: 'Open in browser',
              icon: Icon(KIcons.openInBrowser),
              onPressed: () {
                getIt<BrowserService>()
                    .launchUrl(getIt<BrowserService>().privacyUrl);
              }),
        ],
      ),
      body: FutureBuilder<String>(
          future: privacyReadmeTextFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return AnimateOnBuild(
                child: Markdown(
                  data: snapshot.data,
                  onTapLink: (url) => getIt<BrowserService>().launchUrl(url),
                ),
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

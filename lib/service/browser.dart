import 'package:url_launcher/url_launcher.dart';

import 'globals.dart';

/// Launches the [url] in the default browser.
///
/// Logs a warning if the urlcan not be launched.
Future<bool> launchURL(String url) async {
  final uri = Uri.parse(url);
  final parsedUrl =
  uri.scheme.length > 0 ? uri.toString() : 'http://${uri.toString()}';

  try {
    if (await canLaunch(parsedUrl)) {
      await launch(parsedUrl);
      return true;
    }
  } catch (e) {
    Globals.tree.log('Brower', 'cannot launch url' + ': ' + parsedUrl, ex: e);
  }

  return false;
}

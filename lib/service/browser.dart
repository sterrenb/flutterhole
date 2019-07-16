import 'package:fimber/fimber.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches the [url] in the default browser.
///
/// Logs a warning if the url can not be launched.
Future<bool> launchURL(String url) async {
  try {
    if (await canLaunch(url)) {
      await launch(url);
      return true;
    }
  } catch (e) {
    Fimber.w('cannot launch url' + ': ' + url, ex: e);
  }

  return false;
}

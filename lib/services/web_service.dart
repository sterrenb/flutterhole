import 'package:url_launcher/url_launcher.dart';

class WebService {
  WebService._();

  static void launchUrlInBrowser(String url) async {
    if (!await launch(url)) throw "Could not launch $url";
  }
}

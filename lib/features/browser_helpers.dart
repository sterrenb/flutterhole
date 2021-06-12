import 'package:url_launcher/url_launcher.dart';

Future<bool> launchUrl(String url) async {
  if (await canLaunch(url)) {
    return await launch(url);
  } else {
    print('nope');
    return false;
  }
}

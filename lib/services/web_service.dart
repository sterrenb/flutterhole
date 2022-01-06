import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class WebService {
  WebService._();

  static void launchUrlInBrowser(String url) async {
    if (!await launch(url)) throw "Could not launch $url";
  }

  static Future<String> fetchPlainData(String url) async {
    final Response response = await Dio().get(url);
    return response.data.toString();
  }
}

import 'package:dio/dio.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/browser/services/browser_service.dart';
import 'package:injectable/injectable.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';

@prod
@Singleton(as: BrowserService)
class BrowserServiceImpl implements BrowserService {
  BrowserServiceImpl([Dio dio]) : _dio = dio ?? getIt<Dio>();

  final Dio _dio;

  @override
  String get privacyUrl =>
      'https://raw.githubusercontent.com/sterrenburg/flutterhole/master/PRIVACY.md';

  @override
  Future<void> launchReview() async {
    LaunchReview.launch();
  }

  @override
  Future<bool> launchUrl(String url) async {
    if (await canLaunch(url)) {
      return await launch(url);
    } else {
      return false;
    }
  }

  @override
  Future<String> fetchPrivacyReadmeText() async {
    try {
      final Response response = await _dio.get(privacyUrl);
      return response.data.toString();
    } catch (e) {
      return 'Failed to get privacy information: \n\n$e';
    }
  }
}

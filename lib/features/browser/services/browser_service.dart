abstract class BrowserService {
  String get privacyUrl;

  Future<void> launchUrl(String url);

  Future<void> launchReview();

  Future<String> fetchPrivacyReadmeText();
}

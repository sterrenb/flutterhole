abstract class BrowserService {
  String get privacyUrl;

  Future<bool> launchUrl(String url);

  Future<void> launchReview();

  Future<String> fetchPrivacyReadmeText();
}

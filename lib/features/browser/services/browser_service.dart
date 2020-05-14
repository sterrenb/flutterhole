abstract class BrowserService {
  String get privacyUrl;

  /// Launch [url] in the browser.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> launchUrl(String url);

  /// Open the review platform for the current app ID.
  Future<void> launchReview();

  /// Fetch the plaintext from [privacyUrl].
  Future<String> fetchPrivacyReadmeText();
}

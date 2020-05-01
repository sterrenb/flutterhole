import 'dart:convert';
import 'dart:io';

const fixturePath = 'test/fixtures/';

/// Hack fix for `flutter test` outside IDE
/// https://stackoverflow.com/questions/45780255/flutter-how-to-load-file-for-testing
String _loadFileAsString(String name) {
  final String filePath = '$fixturePath$name';

  String fileString;
  try {
    fileString = File(filePath).readAsStringSync();
  } catch (e) {
    fileString = File("../" + filePath).readAsStringSync();
  }

  return fileString;
}

/// Returns the json representation of the fixture file [name].
///
/// Typically returns a `Map<String, dynamic>` or `List<dynamic>`.
dynamic jsonFixture(String name) {
  final string = _loadFileAsString(name);

  try {
    return jsonDecode(string);
  } catch(_) {
    return string;
  }
}

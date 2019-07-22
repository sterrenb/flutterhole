import 'package:flutter_driver/flutter_driver.dart';
import 'package:screenshots/screenshots.dart';
import 'package:test/test.dart';

void main() {
  group('App', () {
    FlutterDriver driver;
    Map<dynamic, dynamic> configInfo;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      configInfo = Config().configInfo;
    });

    tearDownAll(() async {
      await driver?.close();
    });

    test('check flutter driver health', () async {
      Health health = await driver.checkHealth();
      print(health.status);
    });

    test('picture time', () async {
      print('config: ${configInfo.toString()}');
      await screenshot(driver, configInfo, 'myscreenshot1',
          timeout: Duration(seconds: 3));
    });

//    test('hi', () async {
//      expect(await driver.getText(finder), 'fake');
//    });
  });
}

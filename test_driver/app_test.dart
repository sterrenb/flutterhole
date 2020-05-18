import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

main() {
  group('checking', () {
    FlutterDriver driver;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      driver?.close();
    });

    test('Home page', () async {
      await driver.clearTimeline();

      await driver.tap(find.text('Got it!'));

      await driver.tap(find.text('Total Queries'));

      expect(driver.getText(find.text('Powered by')), completes);

      await driver.tap(find.byTooltip('Back'));

      await driver.scrollIntoView(find.byType('QueryTypesTile'));

      expect(driver.getText(find.text('AAAA (IPv6)')), completes);

      await driver.scrollIntoView(find.byType('ForwardDestinationsTile'));

      await Future.delayed(Duration(seconds: 2));

      await driver.scroll(find.byType('ForwardDestinationsTile'), -300, 0,
          Duration(milliseconds: 500));

//      await Future.delayed(Duration(seconds: 2));

      print('tapping on openelec');

      await driver.tap(find.text('10.0.1.2 (openelec)'));

      await driver.tap(PageBack());

      await driver.scroll(
          find.byType('FrequencyTile'), -300, 0, Duration(milliseconds: 500));

      await Future.delayed(Duration(seconds: 2));
    });
  });
}

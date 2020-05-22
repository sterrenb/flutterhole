import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:ozzie/ozzie.dart';
import 'package:test/test.dart';

main() {
  group('checking', () {
    FlutterDriver driver;
    Ozzie ozzie;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
      ozzie = Ozzie.initWith(
        driver,
        groupName: 'home',
        shouldTakeScreenshots: true,
      );
    });

    tearDownAll(() async {
      print('tearDownAll');

      driver?.close();
      ozzie?.generateHtmlReport();
    });

    test('Home page', () async {
      await driver.clearTimeline();

      await driver.tap(find.text('Got it!'));

      await ozzie.takeScreenshot('summary_0_top');

      await driver.tap(find.text('Total Queries'));

      expect(driver.getText(find.text('Powered by')), completes);

      await ozzie.takeScreenshot('summary_1_numbers_wiki');

      await driver.tap(find.byTooltip('Back'));

      await driver.scrollIntoView(find.byType('QueryTypesTile'));

      await driver.waitFor(find.text('AAAA (IPv6)'));

      await ozzie.takeScreenshot('summary_2_middle');

      await driver.scrollIntoView(find.byType('ForwardDestinationsTile'));

      await ozzie.takeScreenshot('summary_3_bottom');

      await driver.scroll(find.byType('ForwardDestinationsTile'), -300, 0,
          Duration(milliseconds: 500));

      await ozzie.takeScreenshot('clients_0_top');

//      await Future.delayed(Duration(seconds: 2));

      print('tapping on openelec');

      await driver.tap(find.text('10.0.1.2 (openelec)'));

      await ozzie.takeScreenshot('clients_1_single');

      await driver.tap(find.byTooltip('Back'));

      print('done with screenshots');

      exit(0);
    });
  });
}

//      await driver.scroll(
//          find.byType('FrequencyTile'), -300, 0, Duration(milliseconds: 500));
//
//      await Future.delayed(Duration(seconds: 2));

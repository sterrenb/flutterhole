import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/layout/list.dart';
import 'package:flutterhole_web/features/layout/transparent_app_bar.dart';
import 'package:flutterhole_web/features/logging/log_widgets.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/features/settings/themes.dart';

class LogsPage extends HookWidget {
  const LogsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    return ActivePiTheme(
      child: Scaffold(
        appBar: TransparentAppBar(
          controller: controller,
          title: Text(
            'Logs',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyText2!.color),
          ),
          actions: [
            ThemeModeToggle(),
            AddLogTextButton(),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          alignment: Alignment.topRight,
          fit: StackFit.expand,
          children: [
            Scrollbar(
              child: ListView(
                physics: BouncingScrollPhysics(),
                controller: controller,
                children: [
                  AnimatedLogsList(
                    maxLength: kLogsPageCacheLength,
                    shrinkWrap: true,
                    singleLine: false,
                  ),
                  // AnimatedLogsList(controller: controller),
                ],
              ),
            ),
            OverScrollMessage(
              controller: controller,
              height: 200.0,
              threshold: -.8,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('The logs are refreshed automatically.'),
              ),
            ),
            OverScrollMessage(
              controller: controller,
              height: 300.0,
              threshold: -1.5,
              child: Text('Patience is a virtue.'),
            ),
            OverScrollMessage(
              controller: controller,
              height: 400.0,
              threshold: -1.8,
              child: Text('Enough swiping for today.'),
            ),
          ],
        ),
        // body: AnimatedLogsList(controller: controller),
      ),
    );
  }
}

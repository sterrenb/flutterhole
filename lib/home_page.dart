import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/features/home/dashboard_grid.dart';
import 'package:flutterhole_web/features/home/home_app_bar.dart';
import 'package:flutterhole_web/features/layout/app_drawer.dart';
import 'package:flutterhole_web/features/layout/double_back_to_close_app.dart';
import 'package:flutterhole_web/features/pihole/pi_status.dart';
import 'package:flutterhole_web/features/settings/themes.dart';

class HomePage extends HookWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ActivePiTheme(
      child: Scaffold(
        appBar: HomeAppBar(),
        drawer: AppDrawer(),
        body: DoubleBackToCloseApp(child: DashboardGrid()),
        floatingActionButton: PiToggleFloatingActionButton(),
      ),
    );
  }
}

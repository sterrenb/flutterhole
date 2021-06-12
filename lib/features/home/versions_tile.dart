import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/features/browser_helpers.dart';
import 'package:flutterhole_web/features/layout/grid.dart';
import 'package:flutterhole_web/features/pihole/active_pi.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _ListTile extends StatelessWidget {
  const _ListTile({
    Key? key,
    required this.title,
    required this.currentVersion,
    required this.latestVersion,
    required this.branch,
    required this.updateUrl,
  }) : super(key: key);

  final String title;
  final String currentVersion;
  final String latestVersion;
  final String branch;
  final String updateUrl;

  bool get updateIsAvailable => currentVersion != latestVersion;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Text('Branch'),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(currentVersion),
              Visibility(
                visible: updateIsAvailable,
                child: Text(
                  ' (update available: $latestVersion)',
                  style: TextStyle(color: KColors.warning),
                ),
              ),
            ],
          ),
          // Text('Branch'),
          Text(branch),
        ],
      ),
      onTap: () {
        launchUrl(updateUrl);
      },
    );
  }
}

class InvertColors extends StatelessWidget {
  final Widget child;
  final bool invert;

  const InvertColors({
    required this.child,
    this.invert = true,
  });

  @override
  Widget build(BuildContext context) {
    return invert
        ? ColorFiltered(
            colorFilter: ColorFilter.matrix([
              -1,
              0,
              0,
              0,
              255,
              0,
              -1,
              0,
              0,
              255,
              0,
              0,
              -1,
              0,
              255,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: this.child,
          )
        : child;
  }
}

class VersionsTile extends HookWidget {
  const VersionsTile({Key? key}) : super(key: key);

  static const double _tileHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final versionsValue = useProvider(activeVersionsProvider);
    return Card(
      color: KColors.versions,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              context.refresh(
                  piVersionsProvider(context.read(activePiProvider).state));
            },
            title: TileTitle('Versions'),
            // leading: DashboardTileIcon(KIcons.appVersion),
            leading: Opacity(
              opacity: 0.5,
              child: InvertColors(
                invert: Theme.of(context).brightness == Brightness.dark,
                child: Image(
                    width: 32.0,
                    image: AssetImage('assets/icons/pihole_dark.png')),
              ),
            ),
            // trailing: Opacity(
            //     opacity: 0, child: DashboardTileIcon(KIcons.appVersion)),
            trailing: Icon(Icons.refresh),
          ),
          ...versionsValue.when<List<Widget>>(
            loading: () => [
              Container(
                height: _tileHeight * 3,
                child: Center(child: CircularProgressIndicator()),
              )
            ],
            error: (error, stacktrace) => [
              Container(
                  height: _tileHeight * 3,
                  child: Center(child: Text(error.toString()))),
            ],
            data: (versions) => [
              _ListTile(
                title: 'Pi-hole',
                currentVersion: versions.currentCoreVersion,
                latestVersion: versions.latestCoreVersion,
                branch: versions.coreBranch,
                updateUrl: KUrls.piUpdateUrl,
              ),
              _ListTile(
                title: 'Web Interface',
                currentVersion: versions.currentWebVersion,
                latestVersion: versions.latestWebVersion,
                branch: versions.webBranch,
                updateUrl: KUrls.webInterfaceUpdateUrl,
              ),
              _ListTile(
                title: 'FTL',
                currentVersion: versions.currentFtlVersion,
                latestVersion: versions.latestFtlVersion,
                branch: versions.ftlBranch,
                updateUrl: KUrls.ftlUpdateUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

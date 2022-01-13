import 'package:flutter/material.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import '../dashboard_card.dart';

class VersionsTile extends HookConsumerWidget {
  const VersionsTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CacheBuilder<PiVersions>(
      provider: activeVersionsProvider,
      builder: (context, versions, isLoading, error) {
        return DashboardCard(
          id: DashboardID.versions,
          header: DashboardCardHeader(
            title: DashboardID.versions.humanString,
            isLoading: isLoading,
            error: error,
          ),
          onTap: () => ref.refreshVersions(),
          content: AnimatedCardContent(
            isLoading: isLoading,
            child: versions == null
                ? Container()
                : _VersionsList(versions: versions),
          ),
          background: const DashboardBackgroundIcon(DashboardID.versions),
        );
      },
    );
  }
}

class _VersionsList extends HookConsumerWidget {
  const _VersionsList({
    Key? key,
    required this.versions,
  }) : super(key: key);

  final PiVersions versions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final appVersionString = packageInfo.when(
      data: (info) => Formatting.packageInfoToString(info),
      error: (e, s) => '?',
      loading: () => '...',
    );

    return ListView(
      children: [
        _ListTile(
          title: 'Pi-hole',
          currentVersion: versions.currentCoreVersion,
          latestVersion: versions.latestCoreVersion,
          branch: versions.coreBranch,
          updateUrl: KUrls.piUpdateUrl,
        ),
        _ListTile(
          title: 'Web',
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
        _ListTile(
          title: 'FlutterHole',
          currentVersion: appVersionString,
          latestVersion: appVersionString,
          branch: 'web',
          updateUrl: KUrls.githubHomeUrl,
        )
      ],
    );
  }
}

class _ListTile extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(dashboardEntryProvider);

    final bool isBig = entry.constraints.crossAxisCount > 2;

    return Tooltip(
      waitDuration: const Duration(seconds: 1),
      message: updateUrl,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            Visibility(visible: isBig, child: const Text('Branch')),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      currentVersion,
                      style: GoogleFonts.firaMono(),
                    ),
                  ],
                ),
                // Text('Branch'),
                Visibility(
                  visible: isBig,
                  child: Text(
                    branch,
                    style: GoogleFonts.firaMono(),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: updateIsAvailable,
              child: Text(
                '${isBig ? 'Update available: ' : ''}$latestVersion${isBig ? '' : '+'}',
                style: GoogleFonts.firaMono(
                    color: Theme.of(context).colorScheme.secondary),
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        onTap: () {
          WebService.launchUrlInBrowser(updateUrl);
          // launchUrl(updateUrl);
        },
      ),
    );
  }
}

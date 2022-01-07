import 'package:flutter/material.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/layout/animations.dart';
import 'package:flutterhole/widgets/settings/extensions.dart';
import 'package:flutterhole/widgets/ui/cache.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import 'dashboard_card.dart';

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
          content: AnimatedFader(
            child: versions != null
                ? _VersionsList(versions: versions)
                : const _EmptyList(),
          ),
        );
      },
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.filled(
          3,
          const ListTile(
            title: Text(''),
            subtitle: Text(''),
          )),
    );
  }
}

class _VersionsList extends StatelessWidget {
  const _VersionsList({
    Key? key,
    required this.versions,
  }) : super(key: key);

  final PiVersions versions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
    );
  }
}

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
    return Tooltip(
      waitDuration: const Duration(seconds: 1),
      message: updateUrl,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title),
            const Text('Branch'),
          ],
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  currentVersion,
                  style: GoogleFonts.firaMono(),
                ),
                Visibility(
                  visible: updateIsAvailable,
                  child: Text(
                    ' (update available: $latestVersion)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ],
            ),
            // Text('Branch'),
            Text(
              branch,
              style: GoogleFonts.firaMono(),
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

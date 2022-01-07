import 'package:flutter/material.dart';
import 'package:flutterhole/constants/urls.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/services/web_service.dart';
import 'package:flutterhole/widgets/ui/snackbars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension WidgetRefX on WidgetRef {
  void refreshSummary() =>
      refresh(summaryProvider(read(activePiholeParamsProvider)));

  void refreshVersions() =>
      refresh(versionsProvider(read(activePiholeParamsProvider)));

  void refreshDetails() =>
      refresh(detailsProvider(read(activePiholeParamsProvider)));

  void refreshForwardDestinations() =>
      refresh(forwardDestinationsProvider(read(activePiholeParamsProvider)));

  void refreshQueryItems() =>
      refresh(queryItemsProvider(read(activePiholeParamsProvider)));

  void refreshDashboard() {
    refreshSummary();
    refreshVersions();
    refreshDetails();
    refreshForwardDestinations();
    refreshQueryItems();
  }

  void updateThemeMode(
      BuildContext context, ThemeMode oldMode, ThemeMode newMode,
      [String? message]) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    notifier.setThemeMode(newMode);
    highlightSnackBar(
      context,
      content: Text(
        message ?? 'Using ${Formatting.enumToString(newMode)} mode.',
      ),
      undo: () {
        notifier.setThemeMode(oldMode);
      },
    );
  }

  void updatePihole(BuildContext context, Pi oldValue, Pi newValue,
      [String? message]) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    notifier.savePihole(oldValue: oldValue, newValue: newValue);
    highlightSnackBar(
      context,
      content: Text(
        message ?? '${newValue.title} updated.',
      ),
      undo: () {
        notifier.savePihole(oldValue: newValue, newValue: oldValue);
      },
    );
  }

  void updateDashboard(
      BuildContext context, Pi oldValue, List<DashboardEntry> dashboard) {
    updatePihole(
      context,
      oldValue,
      oldValue.copyWith(dashboard: dashboard),
      'Dashboard updated.',
    );
  }

  void updateDashboardEntry(DashboardEntry entry) {
    read(UserPreferencesNotifier.provider.notifier).updateDashboardEntry(entry);
  }

  void moveDashboardEntry(int oldIndex, int newIndex) {
    read(UserPreferencesNotifier.provider.notifier)
        .moveDashboardEntry(oldIndex, newIndex);
  }

  void deletePihole(BuildContext context, Pi oldValue) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    final index = notifier.deletePihole(oldValue);

    highlightSnackBar(
      context,
      content: Text(
        '${oldValue.title} deleted.',
      ),
      undo: () {
        notifier.addPihole(oldValue, index);
      },
    );
  }

  void deletePiholes(BuildContext context) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    final oldValue = notifier.deletePiholes();

    highlightSnackBar(
      context,
      content: const Text('All Pi-holes deleted.'),
      undo: () {
        notifier.savePiholes(oldValue);
      },
    );
  }

  void resetPreferences(BuildContext context) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    final oldValue = notifier.clearPreferences();

    highlightSnackBar(
      context,
      content: const Text('Preferences reset.'),
      undo: () {
        notifier.setPreferences(oldValue);
      },
    );
  }

  void submitGithubIssue({String? title, bool feature = false}) {
    final t = title == null ? '' : '&title=FlutterHole ' + title;

    WebService.launchUrlInBrowser(
        (feature ? KUrls.githubFeatureRequestUrl : KUrls.githubBugReportUrl) +
            t);
  }

  void submitRedditPost(String title, String text) {
    //https://www.reddit.com/r/pihole/submit?title=hello&text=I%20am%20using%20%5BFlutterHole%5D(http%3A%2F%2Fpi.hole)%20v1.2.3.
    WebService.launchUrlInBrowser(
        KUrls.piholeCommunity + 'submit?title=$title&text=$text');
  }
}

import 'package:flutter/material.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_service.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:flutterhole/widgets/ui/snackbars.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension WidgetRefX on WidgetRef {
  void refreshSummary() =>
      refresh(summaryProvider(read(activePiholeParamsProvider)));

  void refreshVersions() =>
      refresh(versionsProvider(read(activePiholeParamsProvider)));

  void refreshDetails() =>
      refresh(detailsProvider(read(activePiholeParamsProvider)));

  void saveDashboard(
      BuildContext context, Pi oldValue, List<DashboardEntry> dashboard) {
    final newValue = oldValue.copyWith(dashboard: dashboard);
    updatePihole(context, oldValue, newValue, 'Dash saved.');
  }

  void updatePihole(BuildContext context, Pi oldValue, Pi newValue,
      [String? message]) {
    final notifier = read(UserPreferencesNotifier.provider.notifier);
    notifier.savePihole(oldValue: oldValue, newValue: newValue);
    highlightSnackBar(
      context,
      content: Text(
        message ?? '${newValue.title} saved.',
      ),
      undo: () {
        notifier.savePihole(oldValue: newValue, newValue: oldValue);
      },
    );
  }
}

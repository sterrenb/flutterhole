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
}

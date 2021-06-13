import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final activeSummaryProvider =
    Provider.autoDispose<AsyncValue<PiSummary>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(piSummaryProvider(pi));
});

final activeTopItemsProvider =
    Provider.autoDispose<AsyncValue<TopItems>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(topItemsProvider(pi));
});

final activeClientActivityProvider =
    Provider.autoDispose<AsyncValue<PiClientActivityOverTime>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(clientActivityOverTimeProvider(pi));
});

final activeVersionsProvider =
    Provider.autoDispose<AsyncValue<PiVersions>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(piVersionsProvider(pi));
});

final activeQueryTypesProvider =
    Provider.autoDispose<AsyncValue<PiQueryTypes>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(queryTypesProvider(pi));
});

final activeForwardDestinationsProvider =
    Provider.autoDispose<AsyncValue<PiForwardDestinations>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(forwardDestinationsProvider(pi));
});

final activeQueriesOverTimeProvider =
    Provider.autoDispose<AsyncValue<PiQueriesOverTime>>((ref) {
  final pi = ref.watch(activePiProvider);
  return ref.watch(queriesOverTimeProvider(pi));
});

class ActivePiTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final pi = useProvider(activePiProvider);
    return Text(pi.title);
  }
}

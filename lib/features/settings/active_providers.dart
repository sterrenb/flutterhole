import 'package:flutterhole_web/features/pihole/pihole_providers.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final activePiParamsProvider = Provider<PiholeRepositoryParams>((ref) {
  final pi = ref.watch(activePiProvider);
  final dio = ref.watch(dioProvider(pi));

  return PiholeRepositoryParams(
    dio: dio,
    baseUrl: pi.baseUrl,
    useSsl: pi.useSsl,
    apiPath: pi.apiPath,
    apiPort: pi.apiPort,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});

final activeSummaryProvider =
    Provider.autoDispose<AsyncValue<PiSummary>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piSummaryProvider(pi));
});

final activeQueryTypesProvider =
    Provider.autoDispose<AsyncValue<PiQueryTypes>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queryTypesProvider(pi));
});

final activeTopItemsProvider =
    Provider.autoDispose<AsyncValue<TopItems>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(topItemsProvider(pi));
});

final activeForwardDestinationsProvider =
    Provider.autoDispose<AsyncValue<PiForwardDestinations>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(forwardDestinationsProvider(pi));
});

final activeQueriesOverTimeProvider =
    Provider.autoDispose<AsyncValue<PiQueriesOverTime>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queriesOverTimeProvider(pi));
});

final activeClientActivityProvider =
    Provider.autoDispose<AsyncValue<PiClientActivityOverTime>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(clientActivityOverTimeProvider(pi));
});

final activeVersionsProvider =
    Provider.autoDispose<AsyncValue<PiVersions>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piVersionsProvider(pi));
});

final activePiDetailsProvider =
    Provider.autoDispose<AsyncValue<PiDetails>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piDetailsProvider(pi));
});

final activeQueryLogProvider =
    Provider.autoDispose<AsyncValue<List<QueryItem>>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queryLogProvider(pi));
});

final piholeStatusNotifierProvider =
    StateNotifierProvider<PiholeStatusNotifier, PiholeStatus>((ref) {
  return PiholeStatusNotifier(ref.watch(
      piholeRepositoryProviderFamily(ref.watch(activePiParamsProvider))));
});

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/demo/demo_api.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final paramsProvider = Provider.family<PiholeRepositoryParams, Pi>((ref, pi) {
  return PiholeRepositoryParams(
    dio: Dio(BaseOptions(baseUrl: pi.baseUrl)),
    baseUrl: pi.baseUrl,
    apiPath: pi.apiPath,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});

final activePiholeParamsProvider = Provider<PiholeRepositoryParams>((ref) {
  final pi = ref.watch(piProvider);
  return ref.watch(paramsProvider(pi));
});

final piholeProvider =
    Provider.family<PiholeRepository, PiholeRepositoryParams>((ref, params) {
  if (params.baseUrl.contains('example')) {
    return DemoApi(params);
  }
  return PiholeRepositoryDio(params);
});

final activePiholeProvider = Provider<PiholeRepository>((ref) {
  final params = ref.watch(activePiholeParamsProvider);
  return ref.watch(piholeProvider(params));
});

final pingProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeRepositoryParams>((ref, params) async {
  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  return pihole.ping(cancelToken);
});

final activePingProvider =
    Provider.autoDispose<AsyncValue<PiholeStatus>>((ref) {
  return ref.watch(pingProvider(ref.watch(activePiholeParamsProvider)));
});

final summaryProvider =
    FutureProvider.autoDispose.family<PiSummary, PiholeRepositoryParams>(
  (ref, params) async {
    final pihole = ref.watch(piholeProvider(params));
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());
    return pihole.fetchSummary(cancelToken);
  },
  dependencies: [piholeProvider, paramsProvider],
);

final activeSummaryProvider =
    Provider.autoDispose<AsyncValue<PiSummary>>((ref) {
  return ref.watch(summaryProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, summaryProvider, activePiholeParamsProvider]);

final versionsProvider =
    FutureProvider.autoDispose.family<PiVersions, PiholeRepositoryParams>(
  (ref, params) async {
    final pihole = ref.watch(piholeProvider(params));
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());
    return pihole.fetchVersions(cancelToken);
  },
  dependencies: [piholeProvider, paramsProvider],
);

final activeVersionsProvider =
    Provider.autoDispose<AsyncValue<PiVersions>>((ref) {
  return ref.watch(versionsProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, versionsProvider, activePiholeParamsProvider]);

final detailsProvider =
    FutureProvider.autoDispose.family<PiDetails, PiholeRepositoryParams>(
  (ref, params) async {
    final pihole = ref.watch(piholeProvider(params));
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());
    return pihole.fetchPiDetails(cancelToken);
  },
  dependencies: [piholeProvider, paramsProvider],
);

// TODO userprefs
const maxResults = 50;

final activeDetailsProvider =
    Provider.autoDispose<AsyncValue<PiDetails>>((ref) {
  return ref.watch(detailsProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, detailsProvider, activePiholeParamsProvider]);

final queryItemsProvider =
    FutureProvider.autoDispose.family<List<QueryItem>, PiholeRepositoryParams>(
  (ref, params) async {
    final pihole = ref.watch(piholeProvider(params));
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());
    return pihole.fetchQueryItems(cancelToken, maxResults);
  },
  dependencies: [piholeProvider, paramsProvider],
);

final activeQueryItemsProvider =
    Provider.autoDispose<AsyncValue<List<QueryItem>>>((ref) {
  return ref.watch(queryItemsProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, queryItemsProvider, activePiholeParamsProvider]);

final forwardDestinationsProvider = FutureProvider.autoDispose
    .family<PiForwardDestinations, PiholeRepositoryParams>((ref, params) async {
  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  if (kDebugMode) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  ref.onDispose(() => cancelToken.cancel());
  return pihole.fetchForwardDestinations(cancelToken);
});

final activeForwardDestinationsProvider =
    Provider.autoDispose<AsyncValue<PiForwardDestinations>>((ref) {
  return ref.watch(
      forwardDestinationsProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [
  piProvider,
  forwardDestinationsProvider,
  activePiholeParamsProvider
]);

final queryTypesProvider = FutureProvider.autoDispose
    .family<PiQueryTypes, PiholeRepositoryParams>((ref, params) async {
  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  if (kDebugMode) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  ref.onDispose(() => cancelToken.cancel());
  return pihole.fetchQueryTypes(cancelToken);
});

final activeQueryTypesProvider =
    Provider.autoDispose<AsyncValue<PiQueryTypes>>((ref) {
  return ref.watch(queryTypesProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, queryTypesProvider, activePiholeParamsProvider]);

class PingNotifier extends StateNotifier<PingStatus> {
  static final provider =
      StateNotifierProvider<PingNotifier, PingStatus>((ref) {
    return PingNotifier(ref.watch(activePiholeProvider));
  });

  PingNotifier(this.api)
      : cancelToken = CancelToken(),
        super(const PingStatus(
          loading: true,
          status: PiholeStatus.enabled(),
        ));

  final PiholeRepository api;
  final CancelToken cancelToken;

  Future<void> enable() async {
    state = state.copyWith(loading: true);
    final x = await api.enable(cancelToken);
    state = state.copyWith(loading: false, status: x);
  }
}

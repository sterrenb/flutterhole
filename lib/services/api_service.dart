import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/demo/demo_api.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final paramsProvider = Provider.family<PiholeApiParams, Pi>((ref, pi) {
  return PiholeApiParams(
    baseUrl: pi.baseUrl,
    apiPath: pi.apiPath,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});

final activePiholeParamsProvider = Provider<PiholeApiParams>((ref) {
  final pi = ref.watch(piProvider);
  return ref.watch(paramsProvider(pi));
});

final piholeProvider =
    Provider.family<PiholeApi, PiholeApiParams>((ref, params) {
  if (params.baseUrl.contains('example')) {
    return DemoApi(params);
  }
  return PiholeApiDio(params: params);
});

final activePiholeProvider = Provider<PiholeApi>((ref) {
  final params = ref.watch(activePiholeParamsProvider);
  return ref.watch(piholeProvider(params));
});

final pingProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeApiParams>((ref, params) async {
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
    FutureProvider.autoDispose.family<PiSummary, PiholeApiParams>(
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
    FutureProvider.autoDispose.family<PiVersions, PiholeApiParams>(
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
    FutureProvider.autoDispose.family<PiDetails, PiholeApiParams>(
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
    FutureProvider.autoDispose.family<List<QueryItem>, PiholeApiParams>(
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
    .family<PiForwardDestinations, PiholeApiParams>((ref, params) async {
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
    .family<PiQueryTypes, PiholeApiParams>((ref, params) async {
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

final queriesOverTimeProvider = FutureProvider.autoDispose
    .family<PiQueriesOverTime, PiholeApiParams>((ref, params) async {
  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  if (kDebugMode) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  ref.onDispose(() => cancelToken.cancel());
  return pihole.fetchQueriesOverTime(cancelToken);
});

final activeQueriesOverTimeProvider =
    Provider.autoDispose<AsyncValue<PiQueriesOverTime>>((ref) {
  return ref
      .watch(queriesOverTimeProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [
  piProvider,
  queriesOverTimeProvider,
  activePiholeParamsProvider
]);

typedef PingCallback = Future<PiholeStatus> Function(CancelToken);

class PingNotifier extends StateNotifier<PingStatus> {
  static final provider =
      StateNotifierProvider<PingNotifier, PingStatus>((ref) {
    final cancelToken = CancelToken();
    ref.onDispose(() => cancelToken.cancel());
    return PingNotifier(ref.watch(activePiholeProvider), cancelToken)..ping();
  });

  PingNotifier(this.api, this.cancelToken)
      : super(const PingStatus(
          loading: true,
          status: PiholeStatus.enabled(),
          error: 'Loading',
        ));

  final PiholeApi api;
  final CancelToken cancelToken;

  Future<void> _try(PingCallback c) async {
    state = state.copyWith(loading: true);
    try {
      final status = await c(cancelToken);
      state = state.copyWith(loading: false, status: status, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }

  Future<void> ping() => _try(api.ping);

  Future<void> enable() => _try(api.enable);

  Future<void> disable() => _try(api.disable);

  Future<void> sleep(Duration duration, DateTime now) async {
    state = state.copyWith(loading: true);
    try {
      final status = await api.sleep(duration, cancelToken);
      state = state.copyWith(
          loading: false,
          status: status.maybeMap(
            disabled: (_) => PiholeStatusSleeping(duration, now),
            sleeping: (s) => s,
            orElse: () => state.status,
          ),
          error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e);
    }
  }
}

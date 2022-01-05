import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/api_repository_demo.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class ApiService {
  ApiService._();
}

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
  if (params.baseUrl.contains('example.com')) {
    return PiholeRepositoryDemo(params);
  }
  return PiholeRepositoryDio(params);
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

final activeDetailsProvider =
    Provider.autoDispose<AsyncValue<PiDetails>>((ref) {
  return ref.watch(detailsProvider(ref.watch(activePiholeParamsProvider)));
}, dependencies: [piProvider, detailsProvider, activePiholeParamsProvider]);

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

extension WidgetRefX on WidgetRef {
  refreshSummary() =>
      refresh(summaryProvider(read(activePiholeParamsProvider)));

  refreshVersions() =>
      refresh(versionsProvider(read(activePiholeParamsProvider)));

  refreshDetails() =>
      refresh(detailsProvider(read(activePiholeParamsProvider)));
}

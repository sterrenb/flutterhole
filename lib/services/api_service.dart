import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:flutterhole/services/settings_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class ApiService {
  ApiService._();
}

final activePiholeParamsProvider = Provider<PiholeRepositoryParams>((ref) {
  final pi = ref.watch(activePiProvider);
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

// final piholeProvider = Provider<PiholeRepository>((ref) {
//   return PiholeRepositoryDio(ref.watch(piholeParamsProvider));
// });

final piholeProvider = Provider.autoDispose
    .family<PiholeRepository, PiholeRepositoryParams>((ref, params) {
  return PiholeRepositoryDio(params);
});

int i = 0;

final pingProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeRepositoryParams>((ref, params) async {
  // i++;
  if (i % 2 == 1) {
    await Future.delayed(const Duration(seconds: 1));
    throw const PiholeApiFailure.notAuthenticated();
  }

  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  return pihole.ping(cancelToken);
});

final activePingProvider =
    Provider.autoDispose<AsyncValue<PiholeStatus>>((ref) {
  return ref.watch(pingProvider(ref.watch(activePiholeParamsProvider)));
});

final summaryProvider = FutureProvider.autoDispose
    .family<PiSummary, PiholeRepositoryParams>((ref, params) async {
  final pihole = ref.watch(piholeProvider(params));
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  return pihole.fetchSummary(cancelToken);
});

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

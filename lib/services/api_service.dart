import 'package:dio/dio.dart';
import 'package:flutterhole/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

class ApiService {
  ApiService._();
}

final piholeParamsProvider = Provider<PiholeRepositoryParams>((ref) {
  // TODO provide pi
  final pi = Pi();
  return PiholeRepositoryParams(
    dio: Dio(BaseOptions(baseUrl: pi.baseUrl)),
    baseUrl: pi.baseUrl,
    apiPath: pi.apiPath,
    apiPort: pi.apiPort,
    apiTokenRequired: pi.apiTokenRequired,
    apiToken: pi.apiToken,
    allowSelfSignedCertificates: pi.allowSelfSignedCertificates,
    adminHome: pi.adminHome,
  );
});

final piholeProvider = Provider<PiholeRepository>((ref) {
  return PiholeRepositoryDio(ref.watch(piholeParamsProvider));
});

int i = 0;

final pingProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeRepositoryParams>((ref, params) async {
  print("pingProvider " + params.baseUrl);
  i++;
  if (i % 2 == 0) {
    await Future.delayed(Duration(seconds: 1));
    throw PiholeApiFailure.cancelled();
  }

  final pihole = ref.watch(piholeProvider);
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());
  return pihole.ping(cancelToken);
});

final activePingProvider =
    Provider.autoDispose<AsyncValue<PiholeStatus>>((ref) {
  return ref.watch(pingProvider(ref.watch(piholeParamsProvider)));
});

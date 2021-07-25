import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

import 'pihole_repository_demo.dart';

final piholeRepositoryProviderFamily =
    Provider.family<PiholeRepository, PiholeRepositoryParams>((ref, params) {
  // TODO use sensible conditional
  if (kDebugMode && true) {
    debugPrint('using demo repository');
    return PiholeRepositoryDemo();
  }

  return PiholeRepositoryDio(params);
});

final piSummaryProvider = FutureProvider.autoDispose
    .family<PiSummary, PiholeRepositoryParams>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final piSummary = await api.fetchSummary(cancelToken);
  ref.maintainState = true;
  return piSummary;
});

final enablePiProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  final newStatus = await api.enable(cancelToken);
  return newStatus;
});

final disablePiProvider = FutureProvider.autoDispose
    .family<PiholeStatus, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  final newStatus = await api.disable(cancelToken);
  return newStatus;
});

final sleepPiProvider = FutureProvider.autoDispose
    .family<PiholeStatus, SleepPiParams>((ref, sleepParams) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(sleepParams.params));
  final newStatus = await api.sleep(sleepParams.duration, cancelToken);
  return newStatus;
});

final queryTypesProvider = FutureProvider.autoDispose
    .family<PiQueryTypes, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchQueryTypes(cancelToken);
});

final topItemsProvider = FutureProvider.autoDispose
    .family<TopItems, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchTopItems(cancelToken);
});

final forwardDestinationsProvider = FutureProvider.autoDispose
    .family<PiForwardDestinations, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchForwardDestinations(cancelToken);
});

final queriesOverTimeProvider = FutureProvider.autoDispose
    .family<PiQueriesOverTime, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchQueriesOverTime(cancelToken);
});

final clientActivityOverTimeProvider = FutureProvider.autoDispose
    .family<PiClientActivityOverTime, PiholeRepositoryParams>(
        (ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchClientActivityOverTime(cancelToken);
});

final piVersionsProvider = FutureProvider.autoDispose
    .family<PiVersions, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchVersions(cancelToken);
});

final piDetailsProvider = FutureProvider.autoDispose
    .family<PiDetails, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  await Future.delayed(const Duration(seconds: 1));
  final api = ref.read(piholeRepositoryProviderFamily(params));
  final piDetails = await api.fetchPiDetails(cancelToken);
  return piDetails;
});

// TODO move somewhere else
final queryLogMaxProvider = StateProvider<int>((ref) {
  return 100;
});

final queryLogProvider = FutureProvider.autoDispose
    .family<List<QueryItem>, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  final maxResults = ref.watch(queryLogMaxProvider).state;
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  final queryItems = await api.fetchQueryItems(cancelToken, maxResults);
  return queryItems;
});

class PiholeStatusNotifier extends StateNotifier<PiholeStatus> {
  final PiholeRepository _repository;
  final CancelToken _cancelToken = CancelToken();

  PiholeStatusNotifier(this._repository) : super(const PiholeStatus.loading());

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _perform(Future<PiholeStatus> action) async {
    state = const PiholeStatus.loading();
    try {
      final result = await action;
      if (mounted) {
        state = result;
      }
    } on PiholeApiFailure catch (e) {
      if (mounted) {
        state = PiholeStatus.failure(e);
      }
    }
  }

  Future<void> ping() {
    return _perform(_repository.ping(_cancelToken));
  }

  Future<void> enable() {
    return _perform(_repository.enable(_cancelToken));
  }

  Future<void> disable() {
    return _perform(_repository.disable(_cancelToken));
  }

  Future<void> sleep(Duration duration) async {
    await _perform(_repository.sleep(duration, _cancelToken));
    Future.delayed(duration).then((_) {
      if (mounted) {
        ping();
      }
    });
  }
}

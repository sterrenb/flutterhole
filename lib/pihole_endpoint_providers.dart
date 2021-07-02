import 'package:dio/dio.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:flutterhole_web/package_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';

final piSummaryProvider = FutureProvider.autoDispose
    .family<PiSummary, PiholeRepositoryParams>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final piSummary = await api.fetchSummary(cancelToken);
  ref.maintainState = true;
  return piSummary;
});

final activeSummaryProvider =
    Provider.autoDispose<AsyncValue<PiSummary>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piSummaryProvider(pi));
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

final activeQueryTypesProvider =
    Provider.autoDispose<AsyncValue<PiQueryTypes>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queryTypesProvider(pi));
});

final topItemsProvider = FutureProvider.autoDispose
    .family<TopItems, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchTopItems(cancelToken);
});

final activeTopItemsProvider =
    Provider.autoDispose<AsyncValue<TopItems>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(topItemsProvider(pi));
});

final forwardDestinationsProvider = FutureProvider.autoDispose
    .family<PiForwardDestinations, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchForwardDestinations(cancelToken);
});

final activeForwardDestinationsProvider =
    Provider.autoDispose<AsyncValue<PiForwardDestinations>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(forwardDestinationsProvider(pi));
});

final queriesOverTimeProvider = FutureProvider.autoDispose
    .family<PiQueriesOverTime, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchQueriesOverTime(cancelToken);
});

final activeQueriesOverTimeProvider =
    Provider.autoDispose<AsyncValue<PiQueriesOverTime>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queriesOverTimeProvider(pi));
});

final clientActivityOverTimeProvider = FutureProvider.autoDispose
    .family<PiClientActivityOverTime, PiholeRepositoryParams>(
        (ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchClientActivityOverTime(cancelToken);
});

final activeClientActivityProvider =
    Provider.autoDispose<AsyncValue<PiClientActivityOverTime>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(clientActivityOverTimeProvider(pi));
});

final piVersionsProvider = FutureProvider.autoDispose
    .family<PiVersions, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  return api.fetchVersions(cancelToken);
});

final activeVersionsProvider =
    Provider.autoDispose<AsyncValue<PiVersions>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piVersionsProvider(pi));
});

final piDetailsProvider = FutureProvider.autoDispose
    .family<PiDetails, PiholeRepositoryParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params));
  final piDetails = await api.fetchPiDetails(cancelToken);
  return piDetails;
});

final activePiDetailsProvider =
    Provider.autoDispose<AsyncValue<PiDetails>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(piDetailsProvider(pi));
});

// TODO move somewhere else
final queryLogMaxProvider = StateProvider<int>((ref) {
  return 10;
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

final activeQueryLogProvider =
    Provider.autoDispose<AsyncValue<List<QueryItem>>>((ref) {
  final pi = ref.watch(activePiParamsProvider);
  return ref.watch(queryLogProvider(pi));
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

final piholeStatusNotifierProvider =
    StateNotifierProvider<PiholeStatusNotifier, PiholeStatus>((ref) {
  return PiholeStatusNotifier(ref.watch(
      piholeRepositoryProviderFamily(ref.watch(activePiParamsProvider))));
});

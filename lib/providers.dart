import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// static String getUserExceptionMessage(DioError dioError) {
// return '${dioError.response.statusCode}: ${dioError.response.statusMessage}.\nURL: ${dioError.request.path}';
// }

final cancelTokenStateProvider = StateProvider<CancelToken>((ref) {
  return CancelToken();
});

final themeModeProvider = StateProvider((_) => ThemeMode.system);

enum TemperatureReading {
  celcius,
  fahrenheit,
  kelvin,
}

final temperatureReadingProvider = StateProvider<TemperatureReading>(
  (_) => TemperatureReading.celcius,
);

final updateFrequencyProvider = StateProvider((_) => Duration(seconds: 10));

final temperatureRangeProvider =
    StateProvider<RangeValues>((_) => RangeValues(30, 70));
final temperatureRangeEnabledProvider = StateProvider<bool>((_) => true);

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

final simplePiProvider = Provider<Pi>((ref) {
  return debugPis.first;
});

final piholeRepositoryProviderFamily =
    Provider.family<PiholeRepository, Pi>((ref, pi) {
  final dio = ref.watch(dioProvider(pi));
  return PiholeRepository(dio, pi);
});

// final piStatusProvider = Provider<AsyncValue<PiholeStatus>>((ref) {
//   final piSummary = ref.watch(piSummaryProvider);
//   return piSummary.whenData((value) => value.status);
// });

final piSummaryProvider =
    FutureProvider.autoDispose.family<PiSummary, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final piSummary = await api.fetchPiSummary(cancelToken);
  // print('sleeping...');
  // await Future.delayed(Duration(seconds: 2));
  ref.read(sumCacheProvider).state = some(piSummary);
  return piSummary;
});

final sumCacheProvider = StateProvider<Option<PiSummary>>((ref) => none());

final enablePiProvider =
    FutureProvider.autoDispose.family<PiholeStatus, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final newStatus = await api.enable(cancelToken);
  return newStatus;
});

final disablePiProvider =
    FutureProvider.autoDispose.family<PiholeStatus, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final newStatus = await api.disable(cancelToken);
  return newStatus;
});

final sleepPiProvider = FutureProvider.autoDispose
    .family<PiholeStatus, SleepPiParams>((ref, params) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(params.pi));
  final newStatus = await api.sleep(params.duration, cancelToken);
  return newStatus;
});

final queryTypesProvider =
    FutureProvider.autoDispose.family<PiQueryTypes, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchQueryTypes(cancelToken);
});

final topItemsProvider =
    FutureProvider.autoDispose.family<TopItems, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchTopItems(cancelToken);
});

final forwardDestinationsProvider = FutureProvider.autoDispose
    .family<PiForwardDestinations, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchForwardDestinations(cancelToken);
});

final queriesOverTimeProvider =
    FutureProvider.autoDispose.family<PiQueriesOverTime, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchQueriesOverTime(cancelToken);
});

final clientActivityOverTimeProvider = FutureProvider.autoDispose
    .family<PiClientActivityOverTime, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchClientActivityOverTime(cancelToken);
});

final piVersionsProvider =
    FutureProvider.autoDispose.family<PiVersions, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  return api.fetchVersions(cancelToken);
});

final piDetailsProvider =
    FutureProvider.autoDispose.family<PiDetails, Pi>((ref, pi) async {
  final cancelToken = CancelToken();
  ref.onDispose(() => cancelToken.cancel());

  final api = ref.read(piholeRepositoryProviderFamily(pi));
  final piDetails = await api.fetchPiDetails();
  ref.read(piDetailsOptionProvider).state = some(piDetails);
  return piDetails;
});

final piDetailsOptionProvider = StateProvider<Option<PiDetails>>((_) => none());

// final piholeStatusProvider =
//     StateProvider<PiholeStatus>((_) => PiholeStatus.loading());

class PiholeStatusNotifier extends StateNotifier<PiholeStatus> {
  final PiholeRepository _repository;
  final CancelToken _cancelToken = CancelToken();

  PiholeStatusNotifier(this._repository) : super(PiholeStatus.loading());

  @override
  void dispose() {
    print('disposing PiholeStatusNotifier');
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _perform(Future<PiholeStatus> action) async {
    state = PiholeStatus.loading();
    // await Future.delayed(Duration(seconds: 3));
    try {
      final result = await action;
      print('result: $result');
      if (mounted) {
        state = result;
      }
    } on PiholeApiFailure catch (e) {
      print('oi: $e ($action)');
      if (mounted) {
        print('mounted == true');
        state = PiholeStatus.failure(e);
      }
    }
  }

  Future<void> ping() {
    print('pinging');
    return _perform(_repository.ping(_cancelToken));
  }

  Future<void> enable() async => _perform(_repository.enable(_cancelToken));

  Future<void> disable() async => _perform(_repository.disable(_cancelToken));

  Future<void> sleep(Duration duration) async {
    await _perform(_repository.sleep(duration, _cancelToken));
    Future.delayed(duration).then((_) {
      print('waking up');
      if (mounted) {
        ping();
      }
    });
    print('scheduled');
  }
}

final piholeStatusNotifierProvider =
    StateNotifierProvider<PiholeStatusNotifier, PiholeStatus>((ref) =>
        PiholeStatusNotifier(ref.watch(
            piholeRepositoryProviderFamily(ref.watch(activePiProvider)))));

class QueryLogNotifier extends StateNotifier<List<QueryItem>> {
  final PiholeRepository _repository;
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  QueryLogNotifier(this._repository) : super([]);

  Future<void> fetchItems([int maxResults = 3]) async {
    final items = await _repository.fetchQueryItems(
      _cancelToken,
      maxResults,
    );
    state = items;
  }

  Future<List<QueryItem>> fetchMore(int pageKey) async {
    final items = await _repository.fetchQueryItems(_cancelToken, 100, pageKey);
    return items;
  }

  void addDummy() {
    final faker = Faker();

    state = [
      QueryItem(
        timestamp: DateTime.now(),
        queryType: "No",
        domain: faker.internet.httpUrl(),
        clientName: faker.internet.ipv4Address(),
        queryStatus: QueryStatus.BlockedWithBlacklist,
        dnsSecStatus: DnsSecStatus.Bogus,
      ),
      ...state,
    ];
  }

  Future<List<QueryItem>> fetchDummies() async {
    return [
      QueryItem(
        timestamp: DateTime.now(),
        queryType: "No",
        domain: faker.internet.httpUrl(),
        clientName: faker.internet.ipv4Address(),
        queryStatus: QueryStatus.BlockedWithBlacklist,
        dnsSecStatus: DnsSecStatus.Bogus,
      ),
      QueryItem(
        timestamp: DateTime.now(),
        queryType: "No",
        domain: faker.internet.httpUrl(),
        clientName: faker.internet.ipv4Address(),
        queryStatus: QueryStatus.BlockedWithBlacklist,
        dnsSecStatus: DnsSecStatus.Bogus,
      ),
      QueryItem(
        timestamp: DateTime.now(),
        queryType: "No",
        domain: faker.internet.httpUrl(),
        clientName: faker.internet.ipv4Address(),
        queryStatus: QueryStatus.BlockedWithBlacklist,
        dnsSecStatus: DnsSecStatus.Bogus,
      ),
    ];
  }
}

final queryLogNotifierProvider =
    StateNotifierProvider<QueryLogNotifier, List<QueryItem>>(
        (ref) => QueryLogNotifier(
              ref.watch(
                  piholeRepositoryProviderFamily(ref.watch(activePiProvider))),
            ));

// final myStatusProvider = StateProvider<PiholeStatus>((ref) {
//   final piSummary = ref.watch(piSummaryProvider);
//   final enable = ref.watch(enablePiProvider);
//
//   for (final value in [piSummary, enable]) {
//     if (value is AsyncLoading) {
//       print("$value is loading");
//       return PiholeStatus.loading();
//     }
//     if (value is AsyncError<PiSummary>) {
//       return PiholeStatus.error(value.error.toString());
//     }
//     if (value is AsyncError<PiholeStatus>) {
//       return PiholeStatus.error(value.error.toString());
//     }
//   }
//
//   // return PiholeStatus.disabled();
//
//   return piSummary.when(
//     data: (data) {
//       print('got sum');
//       return data.status;
//     },
//     loading: () => PiholeStatus.loading(),
//     error: (error, _) {
//       print(error);
//       return PiholeStatus.disabled();
//     },
//   );
// });

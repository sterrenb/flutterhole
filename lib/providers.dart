import 'dart:io';

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

// final dio = Dio(
//   BaseOptions(
//       headers: {
//         HttpHeaders.userAgentHeader: "flutterhole",
//       },
//   )
// );

final dioProvider = Provider<Dio>((_) {
  final dio = Dio();
  dio.options.headers = {
    HttpHeaders.userAgentHeader: "flutterhole",
  };
  dio.options.connectTimeout = 5000;
  dio.options.sendTimeout = 5000;
  dio.options.receiveTimeout = 5000;
  // dio.interceptors.add(LogInterceptor(
  //   requestBody: false,
  //   responseBody: false,
  // ));
  return dio;
});

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

final piStatusProvider = StateProvider((_) => PiholeStatus.loading());

final piholeRepositoryProviderFamily =
    Provider.family<PiholeRepository, Pi>((ref, pi) {
  final dio = ref.read(dioProvider);
  // final cancelToken = CancelToken();
  // ref.onDispose(() {
  //   print('disposing for ${pi.title}');
  //   cancelToken.cancel();
  // });
  print('returning repo for ${pi.title}');
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
  await Future.delayed(Duration(seconds: 2));
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

  Future<void> fetchStatus() async {
    state = PiholeStatus.loading();
    await Future.delayed(Duration(seconds: 1));
    print('fetching status in notifier');
    final result = await _repository.fetchStatus(_cancelToken);
    print('result: $result');
    state = result;
  }

  Future<void> enable() async {
    state = PiholeStatus.loading();
    final result = await _repository.enable(_cancelToken);
    state = result;
  }

  Future<void> disable() async {
    state = PiholeStatus.loading();
    final result = await _repository.disable(_cancelToken);
    state = result;
  }

  Future<void> sleep(Duration duration) async {
    state = PiholeStatus.loading();
    final result = await _repository.sleep(duration, _cancelToken);
    state = result;

    Future.delayed(duration).then((_) {
      print('waking up');
      if (mounted) {
        fetchStatus();
      }
    });
    print('scheduled');
  }
}

final piholeStatusNotifierProvider = StateNotifierProvider((ref) =>
    PiholeStatusNotifier(ref.watch(
        piholeRepositoryProviderFamily(ref.watch(activePiProvider).state))));

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
              ref.watch(piholeRepositoryProviderFamily(
                  ref.watch(activePiProvider).state)),
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

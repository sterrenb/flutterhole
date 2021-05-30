import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info/package_info.dart';

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

final themeModeProvider = StateProvider((_) => ThemeMode.system);

enum TemperatureReading {
  celcius,
  fahrenheit,
  kelvin,
}

final temperatureReadingProvider = StateProvider(
  (_) => TemperatureReading.celcius,
);

final updateFrequencyProvider = StateProvider((_) => Duration(seconds: 10));

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

final activePiProvider = StateProvider((_) => debugPis.first);
final piStatusProvider = StateProvider((_) => PiholeStatus.loading());
final allPisProvider = Provider((_) => debugPis);

final piholeRepositoryProvider = Provider((ref) => PiholeRepository(ref.read));

// final piStatusProvider = Provider<AsyncValue<PiholeStatus>>((ref) {
//   final summary = ref.watch(summaryProvider);
//   return summary.whenData((value) => value.status);
// });

final summaryProvider = FutureProvider<Summary>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  // await Future.delayed(Duration(seconds: 5));
  // status.state = PiholeStatus.loading();

  // await Future.delayed(Duration(seconds: 1));
  try {
    final summary = await api.fetchSummary(pi);
    return summary;
  } catch (e) {
    throw e;
  }
});

final enablePiProvider = FutureProvider<PiholeStatus>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.read(activePiProvider).state;

  final newStatus = await api.enable(pi);
  return newStatus;
});

final disablePiProvider = FutureProvider<PiholeStatus>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.read(activePiProvider).state;
  await Future.delayed(Duration(seconds: 1));

  final newStatus = await api.disable(pi);
  return newStatus;
});

final sleepPiProvider =
    FutureProvider.family<PiholeStatus, Duration>((ref, duration) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.read(activePiProvider).state;
  await Future.delayed(Duration(seconds: 1));

  final newStatus = await api.sleep(pi, duration);
  return newStatus;
});

final queryTypesProvider = FutureProvider<PiQueryTypes>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  return api.fetchQueryTypes(pi);
});

final topItemsProvider = FutureProvider<TopItems>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  await Future.delayed(Duration(seconds: 2));
  return api.fetchTopItems(pi);
});

final forwardDestinationsProvider =
    FutureProvider<PiForwardDestinations>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  return api.fetchForwardDestinations(pi);
});

final queriesOverTimeProvider = FutureProvider<PiQueriesOverTime>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  return api.fetchQueriesOverTime(pi);
});

final piDetailsProvider = FutureProvider<PiDetails>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  final piDetails = await api.fetchPiDetails(pi);
  ref.read(piDetailsOptionProvider).state = some(piDetails);
  return piDetails;
});

final piDetailsOptionProvider = StateProvider<Option<PiDetails>>((_) => none());

// final piholeStatusProvider =
//     StateProvider<PiholeStatus>((_) => PiholeStatus.loading());

class PiholeStatusNotifier extends StateNotifier<PiholeStatus> {
  final PiholeRepository _repository;
  final Pi _pi;

  PiholeStatusNotifier(this._repository, this._pi)
      : super(PiholeStatus.loading());

  Future<void> fetchStatus() async {
    final previousState = state;
    state = PiholeStatus.loading();
    await Future.delayed(Duration(seconds: 1));
    print('fetching status in notifier');
    final result = await _repository.fetchStatus(_pi);
    print('result: $result');
    state = result;
  }

  Future<void> enable() async {
    state = PiholeStatus.loading();
    final result = await _repository.enable(_pi);
    state = result;
  }

  Future<void> disable() async {
    state = PiholeStatus.loading();
    final result = await _repository.disable(_pi);
    state = result;
  }

  Future<void> sleep(Duration duration) async {
    state = PiholeStatus.loading();
    final result = await _repository.sleep(_pi, duration);
    state = result;

    print('sleeping: ${result}');
    Future.delayed(duration).then((_) {
      print('waking up');
      if (mounted) {
        fetchStatus();
      }
    });
    print('scheduled');
  }
}

final piholeStatusNotifierProvider =
    StateNotifierProvider((ref) => PiholeStatusNotifier(
          ref.watch(piholeRepositoryProvider),
          ref.watch(activePiProvider).state,
        ));

class QueryLogNotifier extends StateNotifier<List<QueryItem>> {
  final PiholeRepository _repository;
  final Pi _pi;

  QueryLogNotifier(this._repository, this._pi) : super([]);

  Future<void> fetchItems([int maxResults = 3]) async {
    final items = await _repository.fetchQueryItems(_pi, maxResults);
    state = items;
  }

  Future<List<QueryItem>> fetchMore(int pageKey) async {
    final items = await _repository.fetchQueryItems(_pi, 100, pageKey);
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
              ref.watch(piholeRepositoryProvider),
              ref.watch(activePiProvider).state,
            ));

// final myStatusProvider = StateProvider<PiholeStatus>((ref) {
//   final summary = ref.watch(summaryProvider);
//   final enable = ref.watch(enablePiProvider);
//
//   for (final value in [summary, enable]) {
//     if (value is AsyncLoading) {
//       print("$value is loading");
//       return PiholeStatus.loading();
//     }
//     if (value is AsyncError<Summary>) {
//       return PiholeStatus.error(value.error.toString());
//     }
//     if (value is AsyncError<PiholeStatus>) {
//       return PiholeStatus.error(value.error.toString());
//     }
//   }
//
//   // return PiholeStatus.disabled();
//
//   return summary.when(
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

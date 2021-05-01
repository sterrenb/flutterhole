import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:hooks_riverpod/all.dart';
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

  await Future.delayed(Duration(seconds: 1));
  final summary = await api.fetchSummary(pi);
  // print("setting ${summary.status}");
  // ref.read(piStatusProvider).state = summary.status;
  return summary;
});

final enablePiProvider = FutureProvider<PiholeStatus>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  // final status = ref.read(piStatusProvider);
  final pi = ref.watch(activePiProvider).state;
  await Future.delayed(Duration(seconds: 1));
  throw 'Oh noes';
  return api.enable(pi);
});

final queryTypesProvider = FutureProvider<PiQueryTypes>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  return api.fetchQueryTypes(pi);
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

final myStatusProvider = StateProvider<PiholeStatus>((ref) {
  final summary = ref.watch(summaryProvider);
  final enable = ref.watch(enablePiProvider);

  for (final value in [summary, enable]) {
    if (value is AsyncLoading) {
      print("${value} is loading");
      return PiholeStatus.loading();
    }
    if (value is AsyncError) {
      print("${value} is error");
      return PiholeStatus.error(value.error);
    }
  }

  // return PiholeStatus.disabled();

  return summary.when(
    data: (data) {
      print('got sum');
      return data.status;
    },
    loading: () => PiholeStatus.loading(),
    error: (error, _) {
      print(error);
      return PiholeStatus.disabled();
    },
  );
});

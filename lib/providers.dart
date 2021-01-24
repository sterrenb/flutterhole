import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/pihole_repository.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:package_info/package_info.dart';

final themeModeProvider = StateProvider((_) => ThemeMode.light);

enum TemperatureReading {
  celcius,
  fahrenheit,
  kelvin,
}

final temperatureReadingProvider = StateProvider(
  (_) => TemperatureReading.celcius,
);

final updateFrequencyProvider = StateProvider((_) => Duration(seconds: 2));

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

final dioProvider = Provider<Dio>((_) {
  final dio = Dio();
  dio.options.headers = {
    HttpHeaders.userAgentHeader: "flutterhole",
  };
  dio.options.connectTimeout = 5000;
  dio.options.sendTimeout = 5000;
  dio.options.receiveTimeout = 5000;
  // dio.interceptors.add(LogInterceptor(responseBody: false));
  return dio;
});

final activePiProvider = StateProvider((_) => debugPis.first);
final allPisProvider = Provider((_) => debugPis);

final piholeRepositoryProvider = Provider((ref) => PiholeRepository(ref.read));

final piStatusProvider = Provider<AsyncValue<PiStatus>>((ref) {
  final summary = ref.watch(summaryProvider);
  return summary.whenData((value) => value.status);
});

final summaryProvider = FutureProvider<Summary>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;

  final summary = await api.fetchSummary(pi);
  return summary;
});

final piDetailsProvider = FutureProvider<PiDetails>((ref) async {
  final api = ref.read(piholeRepositoryProvider);
  final pi = ref.watch(activePiProvider).state;
  final piDetails = await api.fetchPiDetails(pi);
  ref.read(piDetailsOptionProvider).state = some(piDetails);
  return piDetails;
});

final piDetailsOptionProvider = StateProvider<Option<PiDetails>>((_) => none());

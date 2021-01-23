import 'dart:io';

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
  celciusAndFahrenheit,
}

final temperatureReadingProvider = StateProvider(
  (_) => TemperatureReading.celcius,
);

final packageInfoProvider =
    FutureProvider<PackageInfo>((_) => PackageInfo.fromPlatform());

final dioProvider = Provider<Dio>((_) {
  final dio = Dio();
  dio.options.headers = {
    HttpHeaders.userAgentHeader: "flutterhole",
  };
  dio.interceptors.add(LogInterceptor(responseBody: false));
  return dio;
});

final activePiProvider = StateProvider((_) => debugPis.first);
final allPisProvider = Provider((_) => debugPis);

final piholeRepositoryProvider = Provider((ref) => PiholeRepository(ref.read));

final piStatusProvider = Provider<AsyncValue<PiStatus>>((ref) {
  final summary = ref.watch(summaryProvider);
  return summary.whenData((value) => value.status);
});

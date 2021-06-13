import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final activePiProvider = StateProvider<Pi>((_) => debugPis.first);

final activePiProvider = Provider<Pi>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.active;
});

final allPisProvider = Provider<List<Pi>>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.allPis;
});

final debugModeProvider = Provider<bool>((ref) {
  return false;
});

final userPreferencesProvider = Provider<UserPreferences>((ref) {
  return UserPreferences.initial();
});

final dioProvider = Provider.family<Dio, Pi>((ref, pi) {
  print('making dio for ${pi.title}');
  final dio = Dio();
  dio.options.headers = {
    HttpHeaders.userAgentHeader: "flutterhole",
  };
  dio.options.connectTimeout = 2000;
  dio.options.sendTimeout = 2000;
  dio.options.receiveTimeout = 2000;

  if (pi.allowSelfSignedCertificates) {
    print('allowSelfSignedCertificates: true!!');
    // https://github.com/flutterchina/dio/issues/32#issuecomment-487401443
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  // dio.interceptors.add(LogInterceptor(
  //   requestBody: false,
  //   responseBody: true,
  // ));
  return dio;
});

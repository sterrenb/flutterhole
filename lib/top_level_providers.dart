import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/logging/loggers.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final activePiProvider = StateProvider<Pi>((_) => debugPis.first);

// final activePiProvider = Provider<Pi>((ref) {
//   final settings = ref.watch(settingsNotifierProvider);
//   return settings.active;
// });

final allPisProvider = Provider<List<Pi>>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.allPis;
});

final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.userPreferences;
});

final logLevelProvider =
    Provider<LogLevel>((ref) => ref.watch(userPreferencesProvider).logLevel);

final oldDioProvider = Provider.family<Dio, Pi>((ref, pi) {
  // final logger = ref.watch(logNotifierProvider.notifier);

  final dio = Dio(BaseOptions(
    baseUrl: pi.dioBase,
    headers: {
      HttpHeaders.userAgentHeader: 'flutterhole',
    },
    connectTimeout: 2000,
    sendTimeout: 2000,
    receiveTimeout: 2000,
  ));

  if (pi.allowSelfSignedCertificates) {
    // https://github.com/flutterchina/dio/issues/32#issuecomment-487401443
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    String params = '';
    if (options.queryParameters.isNotEmpty) {
      params = '?' +
          options.queryParameters.entries
              .map((mapEntry) =>
                  '${mapEntry.key}=${mapEntry.key == 'auth' ? '<auth>' : mapEntry.value}')
              .join('&');
    }
    ref.read(logNotifierProvider.notifier).log(LogCall(
          source: 'dio',
          level: LogLevel.debug,
          // message: '${options.method} ${options.path}$params',
          message: '${options.method} ${options.baseUrl}${options.path}$params',
        ));

    return handler.next(options);
  }, onResponse: (response, handler) {
    return handler.next(response);
  }));
  return dio;
});

import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final dioProvider = Provider.family<Dio, Pi>((ref, pi) {
  final dio = Dio(BaseOptions(
    baseUrl: pi.dioBase,
    // TODO integrate referer header in the mock_dio first
    // headers: {
    //   'referer': 'flutterhole',
    // },
    connectTimeout: 2000,
    sendTimeout: 2000,
    receiveTimeout: 2000,
  ));

  // https://github.com/flutterchina/dio/issues/32#issuecomment-487401443
  if (pi.allowSelfSignedCertificates) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    // String params = '';
    // if (options.queryParameters.isNotEmpty) {
    //   params = '?' +
    //       options.queryParameters.entries
    //           .map((mapEntry) =>
    //               '${mapEntry.key}=${mapEntry.key == 'auth' ? '<auth>' : mapEntry.value}')
    //           .join("&");
    // }
    // ref.read(logNotifierProvider.notifier).log(LogCall(
    //   source: 'dio',
    //   level: LogLevel.debug,
    //   // message: '${options.method} ${options.path}$params',
    //   message: '${options.method} ${options.baseUrl}${options.path}$params',
    // ));

    return handler.next(options);
  }, onResponse: (response, handler) {
    return handler.next(response);
  }));
  return dio;
});

final logLevelProvider =
    Provider<LogLevel>((ref) => ref.watch(userPreferencesProvider).logLevel);

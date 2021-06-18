import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'api_repository.dart';

class DioProviderParams {
  const DioProviderParams(
    this.baseUrl,
    this.allowSelfSignedCertificates,
  );

  final String baseUrl;
  final bool allowSelfSignedCertificates;
}

final dioProvider = Provider.family<Dio, DioProviderParams>((ref, params) {
  // final logger = ref.watch(logNotifierProvider.notifier);

  final dio = Dio(BaseOptions(
    baseUrl: params.baseUrl,
    headers: {
      HttpHeaders.userAgentHeader: "flutterhole",
    },
    connectTimeout: 2000,
    sendTimeout: 2000,
    receiveTimeout: 2000,
  ));

  if (params.allowSelfSignedCertificates) {
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
              .join("&");
    }
    print('TODO ${options.method} ${options.baseUrl}${options.path}$params');
    // ref.read(logNotifierProvider.notifier).log(LogCall(
    //   source: 'dio',
    //   level: LogLevel.debug,
    //   message: '${options.method} ${options.baseUrl}${options.path}$params',
    // ));

    return handler.next(options);
  }, onResponse: (response, handler) {
    return handler.next(response);
  }));
  return dio;
});

final apiRepositoryProvider = Provider.family<ApiRepository, Pi>((ref, pi) {
  final x = ref.watch(dioProvider(DioProviderParams(
    pi.baseUrl,
    pi.allowSelfSignedCertificates,
  )));

  print('making ApiRepository for ${pi.baseApiUrl}');
  return ApiRepository(ApiRepositoryParams(
    x,
    pi.apiPath,
    pi.apiTokenRequired,
    pi.apiToken,
    pi.adminHome,
  ));
});

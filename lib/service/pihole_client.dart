import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/model/top_items.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/model/whitelist.dart';
import 'package:meta/meta.dart';

import 'globals.dart';
import 'local_storage.dart';
import 'pihole_exception.dart';

const String _authParameterKey = 'auth';
const String _logKey = 'client';

class PiholeClient {
  final Dio dio;
  final LocalStorage localStorage;

  void _log(String message, {String tag}) {
    Globals.tree.log(_logKey, message, tag: tag);
  }

  PiholeClient({@required this.dio,
    @required this.localStorage,
    bool logQueries = true}) {
    if (logQueries) {
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        String message = options.uri.toString();
        if (options.queryParameters.containsKey(_authParameterKey)) {
          message = message.replaceAll(
              options.uri.queryParameters[_authParameterKey], 'HIDDEN');
        }

        _log(message, tag: 'request');
        return options;
      }, onResponse: (Response response) {
        _log(response.data.toString(), tag: 'response');
        return response;
      }, onError: (DioError error) {
        _log(error.message, tag: 'error');
        return error;
      }));
    }
  }

  /// Performs an HTTP request with [queryParameters] and returns the response.
  ///
  /// [queryParameters] example:
  /// ```dart
  /// _get({'list': 'white', 'add': true});
  /// ```
  Future<Response> _get(Map<String, dynamic> queryParameters,
      {ResponseType responseType = ResponseType.json}) async {
    try {
      final active = localStorage.active();
      dio.options.baseUrl = 'http://${active.host}:${active.port.toString()}';

      if (active.allowSelfSigned) {
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
            (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      }

      final Response response = await dio.get('/${active.apiPath}',
          queryParameters: queryParameters,
          options: Options(responseType: responseType));

      final String dataString = response.data.toString().toLowerCase();
      if (dataString.contains('not authorized')) {
        throw PiholeException(message: 'not authorized');
      }

      if (dataString.length == 2 && dataString.contains('[]')) {
        throw PiholeException(message: 'empty response');
      }

      if (dataString.contains('<!--')) {
        throw PiholeException(message: 'unexpected plaintext response');
      }

//      await Future.delayed(Duration(seconds: 2));

      return response;
    } on DioError catch (e) {
      _log(e.message, tag: 'dio error');
      throw PiholeException(message: e.message, e: e);
    } on PiholeException catch (e) {
      _log(e.message, tag: 'pihole exception');
      rethrow;
    }
  }

  /// Performs [_get] with the API token set in [queryParameters].
  Future<Response> _getSecure(Map<String, dynamic> queryParameters,
      {ResponseType responseType = ResponseType.json}) async {
    final active = localStorage.active();
    if (active.auth.isEmpty) {
      throw PiholeException(message: 'API token is empty');
    }

    final response = await _get(
        queryParameters..addAll({_authParameterKey: active.auth}),
        responseType: responseType);
    return response;
  }

  /// Tries to convert an HTTP response to a [Status].
  ///
  /// The implicit data type for the response is a [Map<String, dynamic>];
  Status _responseToStatus(Response response) {
    if (response.data is String) {
      return Status.fromString(response.data);
    } else {
      return Status.fromJson(response.data);
    }
  }

  /// Fetches the status from the API, then returns [Status].
  Future<Status> fetchStatus() async {
    Response response = await _get({'status': ''});
    final status = _responseToStatus(response);
    return status;
  }

  /// Enables the Pihole.
  ///
  /// Throws a [PiholeException] if the response is disabled.
  Future<Status> enable() async {
    Response response = await _getSecure({'enable': ''});
    final status = _responseToStatus(response);

    if (status.disabled) {
      throw PiholeException(message: 'failed to enable');
    }

    return status;
  }

  /// Disables the Pihole, optionally for the specified [duration].
  ///
  /// Throws a [PiholeException] if the response is enabled.
  Future<Status> disable([Duration duration]) async {
    Response response =
    await _getSecure({'disable': duration?.inSeconds ?? ''});
    final status = _responseToStatus(response);

    if (status.enabled) {
      throw PiholeException(message: 'failed to disable');
    }

    return status;
  }

  /// Fetches home information from the Pi-hole.
  Future<Summary> fetchSummary() async {
    Response response = await _get({'summaryRaw': ''});
    if (response.data is String) {
      return Summary.fromString(response.data);
    } else {
      return Summary.fromJson(response.data);
    }
  }

  /// Fetches the list of whitelisted domains from the Pi-hole.
  Future<Whitelist> fetchWhitelist() async {
    Response response = await _get({'list': 'white'});
    if (response.data is String) {
      return Whitelist.fromString(response.data);
    } else if (response.data is List<dynamic>) {
      return Whitelist.fromJson(response.data);
    }

    throw PiholeException(
        message: 'unexpected data type ${response.data.runtimeType}',
        e: response);
  }

  /// Adds the trimmed [domain] to the Pi-hole whitelist.
  /// Throws a [PiholeException] if:
  /// - the [domain] String is 0;
  /// - The [domain] is already whitelisted;
  /// - The HTTP response is not parsable.
  Future<void> addToWhitelist(String domain) async {
    if (domain.length == 0) {
      throw PiholeException(message: 'cannot add empty domain to whitelist');
    }

    domain = domain.trim();
    Response response = await _getSecure({'list': 'white', 'add': domain},
        responseType: ResponseType.plain);

    final String dataString = response.data.toString().toLowerCase();

    if (dataString.contains('already exists in whitelist')) {
      throw PiholeException(message: '$domain is already whitelisted');
    }

    if (!dataString
        .contains('adding ${domain.toLowerCase()} to whitelist...')) {
      throw PiholeException(message: 'unexpected whitelist response');
    }
  }

  /// Removes the trimmed [domain] from the Pihole whitelist.
  ///
  /// Throws a [PiholeException] if the domain is empty.
  Future<void> removeFromWhitelist(String domain) async {
    if (domain.length == 0) {
      throw PiholeException(
          message: 'cannot remove empty domain from whitelist');
    }

    domain = domain.trim();
    await _getSecure({'list': 'white', 'sub': domain},
        responseType: ResponseType.plain);
  }

  /// Removes the [originalDomain] from the Pihole whitelist,
  /// then adds the [newDomain] to the Pihole whitelist.
  Future<void> editOnWhitelist(String originalDomain, String newDomain) async {
    await removeFromWhitelist(originalDomain);
    await addToWhitelist(newDomain);
  }

  /// Fetches the exact and wildcard lists of blacklisted domains.
  Future<Blacklist> fetchBlacklist() async {
    Response response = await _get({'list': 'black'});
    if (response.data is String) {
      return Blacklist.fromString(response.data);
    } else if (response.data is List<dynamic>) {
      return Blacklist.fromJson(response.data);
    }

    throw PiholeException(
        message: 'unexpected data type ${response.data.runtimeType}',
        e: response);
  }

  /// Adds a new domain or wildcard to the blacklist.
  /// Wildcards are converted to regex Strings, to stay consistent
  /// with the web interface.
  /// Example: wildcard.com => [wildcardPrefix]wildcard.com[wildcardSuffix].
  ///
  /// Throws if:
  /// - the entry is a duplicate;
  /// - the entry is 'not a valid domain (sic)'.
  Future<void> addToBlacklist(BlacklistItem item) async {
    String entry = item.entry;

    if (item.type == BlacklistType.Wildcard) {
      if (!entry.startsWith(wildcardPrefix)) {
        entry = wildcardPrefix + entry;
      }

      if (!entry.endsWith(wildcardSuffix)) {
        entry = entry + wildcardSuffix;
      }
    }

    Response response = await _getSecure({'list': item.list, 'add': entry},
        responseType: ResponseType.plain);
    final dataString = response.data.toString();
    if (dataString.contains('no need to add')) {
      throw PiholeException(
          message: 'Domain already exists on blacklist', e: response.data);
    }
    if (dataString.contains('not a valid domain')) {
      throw PiholeException(
          message: '$entry is not a valid domain', e: response.data);
    }
  }

  // Removes a domain or wildcard from the blacklist.
  Future<void> removeFromBlacklist(BlacklistItem item) async {
    await _getSecure({'list': item.list, 'sub': item.entry},
        responseType: ResponseType.plain);
  }

  Future<void> editOnBlacklist(BlacklistItem originalItem,
      BlacklistItem newItem) async {
    await addToBlacklist(newItem);
    await removeFromBlacklist(originalItem);
  }

  /// Returns a list of recent [Query]s, at most [max].
  Future<List<Query>> fetchQueries({int max = 100}) async {
    Response response =
    await _getSecure({'getAllQueries': max > 0 ? max.toString() : 1});
    if (response.data is Map<String, dynamic>) {
      try {
        List<Query> queries = [];
        (response.data['data'] as List<dynamic>).forEach((entry) {
          queries.add(Query.fromJson(entry));
        });

        return queries;
      } catch (e) {
        throw PiholeException(message: 'unknown error', e: e);
      }
    }

    throw PiholeException(message: 'unexpected query response', e: response);
  }

  Future<List<Query>> fetchQueriesForClient(String client) async {
    Response response =
    await _getSecure({'getAllQueries': '', 'client': client});
    if (response.data is Map<String, dynamic>) {
      try {
        List<Query> queries = [];
        (response.data['data'] as List<dynamic>).forEach((entry) {
          queries.add(Query.fromJson(entry));
        });

        return queries;
      } catch (e) {
        throw PiholeException(message: 'unknown error', e: e);
      }
    }

    throw PiholeException(message: 'unexpected query response', e: response);
  }

  Future<TopSources> fetchTopSources() async {
    Response response = await _getSecure({'getQuerySources': ''});
    if (response.data is String) {
      return TopSources.fromString(response.data);
    } else {
      return TopSources.fromJson(response.data);
    }
  }

  Future<TopItems> fetchTopItems() async {
    Response response = await _getSecure({'topItems': ''});
    if (response.data is String) {
      return TopItems.fromString(response.data);
    } else {
      return TopItems.fromJson(response.data);
    }
  }
}

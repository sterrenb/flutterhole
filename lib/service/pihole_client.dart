import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/model/api/forward_destinations.dart';
import 'package:flutterhole/model/api/queries_over_time.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/model/api/summary.dart';
import 'package:flutterhole/model/api/top_items.dart';
import 'package:flutterhole/model/api/top_sources.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

import 'globals.dart';
import 'local_storage.dart';
import 'pihole_exception.dart';

const String _authParameterKey = 'auth';
const String _logKey = 'client';

class PiholeClient {
  final Dio dio;
  final LocalStorage localStorage;

  CancelToken token;

  void _log(String message, {String tag}) {
    Globals.tree.log(_logKey, message, tag: tag);
  }

  PiholeClient({@required this.dio,
    @required this.localStorage,
    bool logQueries = true}) {
    token = CancelToken();

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
        _log(response.data
            .toString()
            .length
            .toString(), tag: 'response');
        return response;
      }, onError: (DioError error) {
        _log(error.message, tag: 'error');
        return error;
      }));
    }
  }

  void cancel() {
    dio?.clear();
    token.cancel();
    token = CancelToken();
  }

  /// Performs an HTTP request with [queryParameters] and returns the response.
  ///
  /// [queryParameters] example:
  /// ```dart
  /// _get({'list': 'white', 'add': true});
  /// ```
  Future<Response> _get(Map<String, dynamic> queryParameters,
      {ResponseType responseType = ResponseType.json, Pihole pihole}) async {
    try {
      pihole = pihole ?? localStorage.active();
      dio.options.baseUrl = 'http://${pihole.host}:${pihole.port.toString()}';

      if (pihole.allowSelfSigned) {}

      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        if (pihole.allowSelfSigned) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        }

        if (pihole.proxy.isNotEmpty) {
          if (pihole.proxy.host.isNotEmpty && pihole.proxy.port != null) {
            print('using proxy: ${pihole.proxy.host}:${pihole.proxy.port}');
            client.findProxy = (uri) {
              return "PROXY ${pihole.proxy.host}:${pihole.proxy.port}";
            };
          }
        }

        return client;
      };

      final Response response = await dio.get('/${pihole.apiPath}',
          queryParameters: queryParameters,
          options: Options(responseType: responseType),
          cancelToken: token);

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
      {ResponseType responseType = ResponseType.json, Pihole pihole}) async {
    pihole = pihole ?? localStorage.active();
    if (pihole.auth.isEmpty) {
      throw PiholeException(message: 'API token is empty');
    }

    final response = await _get(
        queryParameters..addAll({_authParameterKey: pihole.auth}),
        responseType: responseType,
        pihole: pihole);
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
    } else {
      return Whitelist.fromJson(response.data);
    }
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
    } else {
      return Blacklist.fromJson(response.data);
    }
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

    Response response = await _getSecure({'list': item.addList, 'add': entry},
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
    await _getSecure({'list': item.addList, 'sub': item.entry},
        responseType: ResponseType.plain);
  }

  Future<void> editOnBlacklist(BlacklistItem originalItem,
      BlacklistItem newItem) async {
    await addToBlacklist(newItem);
    await removeFromBlacklist(originalItem);
  }

  /// Returns a list of recent [Query]s, at most [max].
  Future<List<Query>> fetchQueries({int max = 1000}) async {
    Response response =
    await _getSecure({'getAllQueries': max > 0 ? max.toString() : 1});
    return _responseToQueries(response);
  }

  List<Query> _stringToQueries(Response response) {
    List<Query> queries = [];

    final data = json.decode(response.data);
    (data as List<dynamic>).forEach((entry) {
      queries.add(Query.fromJson(entry));
    });

    return queries;
  }

//  List<Query> _responseToQueries(Response response) {
  List<Query> _listToQueries(List<dynamic> data) {
    List<Query> queries = [];
    data.forEach((entry) {
      queries.add(Query.fromJson(entry));
    });

    return queries;
  }

  List<Query> _responseToQueries(Response response) {
    if (response.data is Map<String, dynamic>) {
      try {
        return _listToQueries(response.data['data']);
      } catch (e) {
        throw PiholeException(message: 'unknown error', e: e);
      }
    } else {
      return _stringToQueries(response);
    }
  }

  Future<List<Query>> fetchQueriesForClient(String client) async {
    Response response =
    await _getSecure({'getAllQueries': '', 'client': client});
    return _responseToQueries(response);
  }

  Future<List<Query>> fetchQueriesForQueryType(QueryType type) async {
    Response response = await _getSecure(
        {'getAllQueries': '', 'querytype': QueryType.values.indexOf(type) + 1});
    return _responseToQueries(response);
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

  Future<Versions> fetchVersions([Pihole pihole]) async {
    Response response = await _get({'versions': ''}, pihole: pihole);
    if (response.data is String) {
      return Versions.fromString(response.data);
    } else {
      return Versions.fromJson(response.data);
    }
  }

  Future<QueryTypes> fetchQueryTypes() async {
    Response response = await _getSecure({'getQueryTypes': ''});
    if (response.data is String) {
      return QueryTypes.fromString(response.data);
    } else {
      return QueryTypes.fromJson(response.data);
    }
  }

  Future<ForwardDestinations> fetchForwardDestinations() async {
    Response response = await _getSecure({'getForwardDestinations': ''});
    if (response.data is String) {
      return ForwardDestinations.fromString(response.data);
    } else {
      return ForwardDestinations.fromJson(response.data);
    }
  }

  Future<QueriesOverTime> fetchQueriesOverTime() async {
    Response response = await _get({'overTimeData10mins': ''});
    if (response.data is String) {
      return QueriesOverTime.fromString(response.data);
    } else {
      return QueriesOverTime.fromJson(response.data);
    }
  }
}

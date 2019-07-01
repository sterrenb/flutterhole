import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';
import 'package:flutterhole_again/model/model.dart';
import 'package:meta/meta.dart';

import 'pihole_exception.dart';

class PiholeClient {
  Dio dio;

  final logger = FimberLog('PiholeClient');

  PiholeClient({@required this.dio, bool logQueries = true}) {
    if (logQueries) {
      dio.interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        logger.i('request: ${options.uri.toString()}');
        return options;
      }, onResponse: (Response response) {
        logger.i('response: ${response.data.toString()}');
        return response;
      }, onError: (DioError error) {
        logger.e('error: ${error.message}');
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
    Response response;
    try {
      response = await dio.get('',
          queryParameters: queryParameters,
          options: Options(responseType: responseType));

      final String dataString = response.data.toString().toLowerCase();
      if (dataString.contains('not authorized')) {
        throw PiholeException(message: 'not authorized');
      }

      if (dataString.length == 2 && dataString.contains('[]')) {
        throw PiholeException(message: 'empty response');
      }

      return response;
    } on DioError catch (e) {
      throw PiholeException(message: 'request failed', e: e);
    } catch (e) {
      throw PiholeException(message: 'unknown error', e: e);
    }
  }

  /// Performs [_get] with the API token set in [queryParameters].
  Future<Response> _getSecure(Map<String, dynamic> queryParameters,
      {ResponseType responseType = ResponseType.json}) async {
    final response = await _get(
        queryParameters
          ..addAll({
            'auth':
                '3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c'
          }),
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
      return Status.fromMap(response.data);
    }
  }

  /// Fetches the status from the API, then returns true if enabled.
  Future<bool> fetchEnabled() async {
    Response response = await _get({'status': ''});
    final status = _responseToStatus(response);
    return status.enabled;
  }

  /// Enables the Pihole.
  ///
  /// Throws a [PiholeException] if the response is disabled.
  Future<void> enable() async {
    Response response = await _getSecure({'enable': ''});
    final status = _responseToStatus(response);

    if (status.disabled) {
      throw PiholeException(message: 'failed to enable');
    }

    return true;
  }

  /// Disables the Pihole, optionally for the specified [duration].
  ///
  /// Throws a [PiholeException] if the response is enabled.
  Future<void> disable({Duration duration}) async {
    Response response =
        await _getSecure({'disable': duration?.inSeconds ?? ''});
    final status = _responseToStatus(response);

    if (status.enabled) {
      throw PiholeException(message: 'failed to disable');
    }
  }

  /// Fetches summary information from the Pi-hole.
  Future<Summary> fetchSummary() async {
    Response response = await _get({'summaryRaw': ''});
    if (response.data is String) {
      return Summary.fromJson(response.data);
    } else {
      return Summary.fromMap(response.data);
    }
  }

  /// Fetches the list of whitelisted domains from the Pi-hole.
  Future<Whitelist> fetchWhitelist() async {
    Response response = await _get({'list': 'white'});
    if (response.data is String) {
      return Whitelist.fromString(response.data);
    } else {
      throw PiholeException(
          message: 'unexpected data type ${response.data.runtimeType}',
          e: response);
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
      throw PiholeException(message: 'unexpected response', e: response);
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
    return Blacklist.fromJson(response.data);
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
    Response response = await _getSecure({'list': item.listKey, 'add': entry},
        responseType: ResponseType.plain);
    if (response.data.toString().indexOf('already exists') >= 0) {
      throw PiholeException(
          message: 'Domain already exists on blacklist', e: response.data);
    }
    if (response.data.toString().indexOf('not a valid domain') >= 0) {
      throw PiholeException(
          message: '$entry is not a valid domain', e: response.data);
    }
  }

  // Removes a domain or wildcard from the blacklist.
  Future<void> removeFromBlacklist(BlacklistItem item) async {
    await _getSecure({'list': item.listKey, 'sub': item.entry},
        responseType: ResponseType.plain);
  }

  Future<void> editOnBlacklist(
      BlacklistItem originalItem, BlacklistItem newItem) async {
    await addToBlacklist(newItem);
    await removeFromBlacklist(originalItem);
  }
}

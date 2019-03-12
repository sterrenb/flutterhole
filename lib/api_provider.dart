import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_api_path.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_hostname.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_port.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_ssl.dart';
import 'package:sterrenburg.github.flutterhole/widgets/preferences/preference_token.dart';
import 'package:url_launcher/url_launcher.dart';

/// The relative path to the Pi-hole® API
//const String apiPath = 'admin/api.php';

/// The timeout duration for API requests.
const Duration timeout = Duration(seconds: 2);

/// A convenient wrapper for the Pi-hole® PHP API.
class ApiProvider {
  Client client;
  final log = Logger('ApiProvider');

  ApiProvider({this.client}) {
    if (this.client == null) {
      this.client = Client();
    }
  }

  /// Returns a bool depending on the Pi-hole® status string
  static bool statusToBool(dynamic json) {
    switch (json['status']) {
      case 'enabled':
        return true;
      case 'disabled':
        return false;
      default:
        throw Exception('invalid status response');
    }
  }

  /// Returns the domain based on the [PreferenceHostname] and [PreferencePort].
  static String domain(String hostname, int port) {
    String portString;
    if (port == 80) {
      portString = '';
    } else {
      portString = ':' + port.toString();
    }
    return hostname + portString;
  }

  /// Launches the [url] in the default browser.
  ///
  /// Shows a toast if the url can not be launched.
  Future<bool> launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
        return true;
      }
    } catch (e) {
      log.warning('cannot launch url' + ': ' + url);
    }

    return false;
  }

  /// Returns a widget with a hyperlink that can be tapped to launch using [launchURL].
  static TextSpan hyperLink(String urlString) {
    return TextSpan(
        text: urlString,
        style: TextStyle(
          color: Colors.blue,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => ApiProvider().launchURL(urlString));
  }

  /// Returns the result of an API request based on the [params]. Set [authorization] to true when performing administrative tasks.
  ///
  /// Throws an [Exception] if the request times out.
  ///
  /// ```dart
  /// Api.fetch({'summaryRaw': ''})
  /// Api.fetch({'enabled': '123'}, authorization: true)
  /// ```
  Future<http.Response> fetch(Map<String, String> params,
      {bool authorization = false}) async {
    if (authorization) {
      params['auth'] = await PreferenceToken().get();
    }

    final int port = await PreferencePort().get();
    final String host = await PreferenceHostname().get() +
        (port == 80 ? '' : ':' + port.toString());
    final bool useSSL = await PreferenceSSL().get();
    final String apiPath = await PreferenceApiPath().get();
    final Uri uri = useSSL
        ? Uri.https(host, apiPath, params)
        : Uri.http(host, apiPath, params);
    final response = await client.get(uri).timeout(timeout, onTimeout: () {
      final String message =
          'Request timed out after ${timeout.inSeconds
          .toString()} seconds - is your port correct?';
      log.warning(uri.toString() + ': ' + message);
      throw Exception(message);
    });
    if (response.statusCode != 200 ||
        // this is the common response for unauthorized requests
        response.body == '[]' ||
        // if the API path is incorrect, the request returns the Pi-hole hostname.
        // here we loosely check whether the homepage was obtained, indicating an error.
        response.contentLength > 10000) {
      throw Exception(
          'Failed to fetch data, even though the server sent a response: ${response
              .statusCode} ${response
              .reasonPhrase}\n\See if your API token and API path correspond to your Pi-hole.');
    }
    log.fine(authorization && params['auth'].length > 0
        ? uri.toString().replaceAll(params['auth'], '<HIDDEN_TOKEN>')
        : uri.toString());
    return response;
  }

  /// Returns true if the Pi-hole® is enabled, or false when disabled.
  ///
  /// Throws an [Exception] when the request fails.
  Future<bool> fetchEnabled() async {
    http.Response response;
    try {
      response = await fetch({'status': ''});
    } catch (e) {
      rethrow;
    }
    final bool status = statusToBool(json.decode(response.body));
    return status;
  }

  /// Sets the status of the Pi-hole® to 'enabled' or 'disabled' based on [newStatus].
  ///
  /// Optionally, specify a duration for the action.
  ///
  /// Returns the new status after performing the request.
  ///
  /// Shows a toast when any request fails.
  Future<bool> setStatus(bool newStatus, {Duration duration}) async {
    final String activity = newStatus ? 'enable' : 'disable';
    Map<String, String> params = {activity: ''};
    if (!newStatus && duration != null)
      params[activity] = duration.inSeconds.toString();

    http.Response response;
    try {
      response = await fetch(params, authorization: true);
    } catch (e) {
      rethrow;
    }
    return statusToBool(json.decode(response.body));
  }

  /// Returns true if the request is authorized, or false when unauthorized.
  Future<bool> isAuthorized() async {
    http.Response response;
    try {
      response = await fetch({'topItems': ''}, authorization: true);
      if (response.statusCode == 200 && response.contentLength > 2) {
        return true;
      }
    } catch (e) {
      log.warning('not authorized: ${e.toString()}');
    }
    return false;
  }

  /// Returns the [SummaryModel of the Pi-hole.
  ///
  /// Throws an [Exception when the request fails.
  Future<SummaryModel> fetchSummary() async {
    final http.Response response = await fetch({'summary': ''});
    Map<String, dynamic> map = jsonDecode(response.body);
    if (map.isNotEmpty) {
      try {
        final SummaryModel model = SummaryModel.fromJson(map);
        return model;
      } catch (e) {}
    }

    throw Exception('Failed to fetch summary');
  }

  /// Returns the most recently blocked domain.
  ///
  /// The PHP API is limited to only the single most recently blocked domain, so unfortunately batching is not possible without frequently sending the same request.
  ///
  /// Throws an [Exception] when the request fails.
  Future<String> recentlyBlocked() async {
    http.Response response;
    try {
      response = await fetch({'recentBlocked': ''}, authorization: false);
    } catch (e) {
      rethrow;
    }

    return response.body;
  }
}

class SummaryModel {
  static const String _totalQueriesTitle = 'dns_queries_today';
  static const String _queriesBlockedTitle = 'ads_blocked_today';
  static const String _percentBlockedTitle = 'ads_percentage_today';
  static const String _domainsOnBlocklistTitle = 'domains_being_blocked';

  final int totalQueries;
  final int queriesBlocked;
  final double percentBlocked;
  final int domainsOnBlocklist;

  SummaryModel({this.totalQueries = 0,
    this.queriesBlocked = 0,
    this.percentBlocked = 0.0,
    this.domainsOnBlocklist = 0});

  static _stringToInt(String string) =>
      int.tryParse(string.replaceAll(',', '')) ?? 0;

  SummaryModel.fromJson(Map<String, dynamic> json)
      : totalQueries = _stringToInt(json[_totalQueriesTitle]),
        queriesBlocked = _stringToInt(json[_queriesBlockedTitle]),
        percentBlocked = double.parse(json[_percentBlockedTitle]),
        domainsOnBlocklist = _stringToInt(json[_domainsOnBlocklistTitle]);

  Map<String, dynamic> toJson() =>
      {
        _totalQueriesTitle: totalQueries.toString(),
        _queriesBlockedTitle: queriesBlocked.toString(),
        _percentBlockedTitle: percentBlocked.toString(),
        _domainsOnBlocklistTitle: domainsOnBlocklist.toString(),
      };
}

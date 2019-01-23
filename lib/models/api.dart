import 'dart:async';
import 'dart:convert';

import 'package:flutter_hole/models/preferences/preference_hostname.dart';
import 'package:flutter_hole/models/preferences/preference_port.dart';
import 'package:flutter_hole/models/preferences/preference_token.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

const String apiPath = 'admin/api.php';

const int timeout = 2;

class Api {
  static _statusToBool(dynamic json) {
    switch (json['status']) {
      case 'enabled':
        return true;
      case 'disabled':
        return false;
      default:
        throw Exception('invalid status response');
    }
  }

  static _domain() async {
    // TODO debug
//    return 'http://pi.hole/admin/api.php';

    final String hostname = await PreferenceHostname().get();
    String port = await PreferencePort().get();
    if (port == '80') {
      port = '';
    } else {
      port = ':' + port;
    }

    return 'http://' + hostname + port + '/' + apiPath;
  }

  static Future<http.Response> _fetch(String params,
      {bool authorization = false}) async {
    if (authorization) {
      String token = await PreferenceToken().get();
      params = params + '&auth=$token';
    }
    String uriString = (await _domain()) + '?' + params;
//    print('fetch: $uriString');
    final result = await http.get(uriString).timeout(Duration(seconds: timeout),
        onTimeout: () =>
        throw Exception(
            'Request timed out after $timeout seconds - is your port correct?'));
    return result;
  }

  static Future<bool> fetchStatus() async {
    http.Response response;
    try {
      response = await _fetch('status');
    } catch (e) {
      print('fetchStatus: _fetch exception');
      rethrow;
    }
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  static Future<bool> setStatus(bool newStatus) async {
    final String activity = newStatus ? 'enable' : 'disable';
    http.Response response;
    try {
      response = await _fetch(activity, authorization: true);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Cannot connect to your Pi-hole');
      return false;
    }
    if (response.statusCode == 200 && response.contentLength > 2) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      Fluttertoast.showToast(msg: 'Cannot $activity Pi-hole');
      return false;
    }
  }

  static Future<bool> isAuthorized() async {
    http.Response response;
    try {
      response = await _fetch('topItems', authorization: true);
    } catch (e) {
      print('isAuthorized: _fetch exception');
      rethrow;
    }
    if (response.statusCode == 200 && response.contentLength > 2) {
      return true;
    }

    return false;
  }

  static Future<Map<String, String>> fetchSummary() async {
    const Map<String, String> _prettySummary = {
      'dns_queries_today': 'Total Queries',
      'ads_blocked_today': 'Queries Blocked',
      'ads_percentage_today': 'Percent Blocked',
      'domains_being_blocked': 'Domains on Blocklist',
    };

    http.Response response;

    try {
      response = await _fetch('summary');
    } catch (e) {
      print('fetchSummary: _fetch exception');
      if (e.osError.errorCode == 7) {
        throw Exception(
            'Host lookup failed.\n\nIs your Pi-hole address correct?');
      }

      rethrow;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      Map<String, String> finalMap = {};
      if (map.isNotEmpty) {
        _prettySummary.forEach((String oldKey, String newKey) {
          if (newKey.contains('Percent')) {
            map[oldKey] += '%';
          }
          finalMap[newKey] = map[oldKey];
        });
        return finalMap;
      }
    } else {
      throw Exception(
          'Failed to fetch summary, status code: ${response.statusCode}');
    }

    throw Exception('Failed to fetch summary');
  }

  static Future<String> recentlyBlocked() async {
    http.Response response;
    try {
      response = await _fetch('recentBlocked', authorization: false);
    } catch (e) {
      print('recentlyBlocked: _fetch exception');
      rethrow;
    }

    return response.body;
  }
}

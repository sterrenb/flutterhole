import 'dart:async';
import 'dart:convert';

import 'package:flutter_hole/models/preferences/preference_hostname.dart';
import 'package:flutter_hole/models/preferences/preference_port.dart';
import 'package:http/http.dart' as http;

const TOKEN =
    '3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c';

const String apiPath = 'admin/api.php';

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
    return 'http://pi.hole/admin/api.php';

    final String hostname = await PreferenceHostname().get();
    String port = await PreferencePort().get();
    if (port == '80') {
      port = '';
    } else {
      port = port + ':';
    }

    return 'http://' + hostname + port + '/' + apiPath;
  }

  static Future<http.Response> _fetch(String params) async {
    final String uriString = (await _domain()) + '?' + params;
    print('fetch: $uriString');
    return await http.get(uriString).timeout(Duration(seconds: 10));
  }

  static Future<bool> fetchStatus() async {
    final response = await _fetch('status');
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  static Future<bool> setStatus(bool newStatus) async {
    final String activity = newStatus ? 'enable' : 'disable';
    final response = await _fetch('$activity&auth=$TOKEN');
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to set status');
    }
  }

  static Future<Map<String, String>> fetchSummary() async {
    const Map<String, String> _prettySummary = {
      'dns_queries_today': 'Total Queries',
      'ads_blocked_today': 'Queries Blocked',
      'ads_percentage_today': 'Percent Blocked',
      'domains_being_blocked': 'Domains on Blocklist',
    };

    print('fetchSummary: awaiting _fetch');
    try {
      final response = await _fetch('summary');

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
    } catch (e) {
      throw e;
    }

//    throw Exception('Failed to fetch summary');
  }
}

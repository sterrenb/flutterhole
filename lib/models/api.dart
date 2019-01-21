import 'dart:convert';

import 'package:http/http.dart' as http;

const TOKEN =
    '3f4fa74468f336df5c4cf1d343d160f8948375732f82ea1a057138ae7d35055c';

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

  static Future<bool> fetchStatus() async {
    final response = await http.get('http://pi.hole/admin/api.php?status');
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to fetch status');
    }
  }

  static Future<bool> setStatus(bool newStatus) async {
    final String activity = newStatus ? 'enable' : 'disable';
    final response =
        await http.get('http://pi.hole/admin/api.php?$activity&auth=$TOKEN');
    if (response.statusCode == 200) {
      final bool status = _statusToBool(json.decode(response.body));
      return status;
    } else {
      throw Exception('Failed to set status');
    }
  }
}

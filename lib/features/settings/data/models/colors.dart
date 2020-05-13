import 'package:flutter/material.dart';

/// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
Color colorFromHex(String hexString) {
  if (hexString == null || hexString.isEmpty) {
    return Colors.blue;
  }

  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
String colorToHex(Color color, {bool leadingHashSign = true}) =>
    '${leadingHashSign ? '#' : ''}'
    '${color.alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${color.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${color.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
    '${color.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';

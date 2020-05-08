import 'package:flutter/material.dart';

/// Shade map for using a [Color] as [MaterialColor].
///
/// ```dart
/// // Purpleish
/// MaterialColor(0xFF880E4F, _materialShades),
/// // Black
/// MaterialColor(0xFF880E4F, _materialShades)
/// ```
const Map<int, Color> _materialShades = {
  50: Color.fromRGBO(136, 14, 79, .1),
  100: Color.fromRGBO(136, 14, 79, .2),
  200: Color.fromRGBO(136, 14, 79, .3),
  300: Color.fromRGBO(136, 14, 79, .4),
  400: Color.fromRGBO(136, 14, 79, .5),
  500: Color.fromRGBO(136, 14, 79, .6),
  600: Color.fromRGBO(136, 14, 79, .7),
  700: Color.fromRGBO(136, 14, 79, .8),
  800: Color.fromRGBO(136, 14, 79, .9),
  900: Color.fromRGBO(136, 14, 79, 1),
};

/// Based on [Colors.primaries].
const Map<String, MaterialColor> namedMaterialColors = {
  'red': Colors.red,
  'pink': Colors.pink,
  'purple': Colors.purple,
  'deepPurple': Colors.deepPurple,
  'indigo': Colors.indigo,
  'blue': Colors.blue,
  'lightBlue': Colors.lightBlue,
  'cyan': Colors.cyan,
  'teal': Colors.teal,
  'green': Colors.green,
  'lightGreen': Colors.lightGreen,
  'lime': Colors.lime,
  'yellow': Colors.yellow,
  'amber': Colors.amber,
  'orange': Colors.orange,
  'deepOrange': Colors.deepOrange,
  'brown': Colors.brown,
  'blueGrey': Colors.blueGrey,
  'purpleish': MaterialColor(0xFF880E4F, _materialShades),
  'darkGrey': MaterialColor(0xFF212121, _materialShades),
  'coolGrey': MaterialColor(0xFF263238, _materialShades),
  'trueBlack': MaterialColor(0xFF000000, _materialShades),
};

MaterialColor valueToMaterialColor(dynamic value) {
  if (value == null) return null;
  return namedMaterialColors[
      namedMaterialColors.keys.firstWhere((key) => key == value, orElse: null)];
}

dynamic materialColorToValue(MaterialColor color) {
  if (color == null) return null;
  return namedMaterialColors.entries
      .firstWhere(
          (MapEntry<String, MaterialColor> entry) => entry.value == color)
      .key;
}
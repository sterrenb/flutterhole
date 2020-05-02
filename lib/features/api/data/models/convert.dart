DateTime dateTimeFromPiholeString(String key) => DateTime.fromMillisecondsSinceEpoch(int.tryParse(key) * 100);

String piholeStringFromDateTime(DateTime key) => '${key.millisecondsSinceEpoch ~/ 100}';

String enumToString(dynamic value) => value.toString();
import 'package:jiffy/jiffy.dart';

DateTime dateTimeFromPiholeString(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key + '000'));

String piholeStringFromDateTime(DateTime key) =>
    '${key.millisecondsSinceEpoch ~/ 1000}';

DateTime dateTimeFromPiholeInt(int key) =>
    DateTime.fromMillisecondsSinceEpoch(key * 1000);

int piholeIntFromDateTime(DateTime key) => key.millisecondsSinceEpoch ~/ 1000;

extension DateTimeWithRelative on DateTime {
  String get fromNow => Jiffy(this).fromNow();

  String get formattedDate => Jiffy(this).format('yyyy-MM-d');

  String get formattedTime => Jiffy(this).format('h:mm:ss a');

  String get formattedTimeShort => Jiffy(this).format('hh:mm');
}

extension StringExtension on String {
  String get capitalize {
    if (this == null) {
      throw ArgumentError("this: $this");
    }

    if (this.isEmpty) {
      return this;
    }

    return this[0].toUpperCase() + this.substring(1);
  }
}

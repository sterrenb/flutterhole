import 'package:jiffy/jiffy.dart';

DateTime dateTimeFromPiholeString(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key + '000'));

String piholeStringFromDateTime(DateTime key) =>
    '${key.millisecondsSinceEpoch ~/ 1000}';

extension DateTimeWithRelative on DateTime {
  String get fromNow => Jiffy(this).fromNow();

  String get formattedDate => Jiffy(this).format('yyyy-MM-d');

  String get formattedTime => Jiffy(this).format('h:mm:ss a');
}

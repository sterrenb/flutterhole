import 'package:intl/intl.dart';

const importDateFormatting = null;

final _hm = DateFormat.Hm();
final _hms = DateFormat.Hms();
final _jms = DateFormat('H:m:s.S');
final _full = DateFormat.yMd().addPattern(_hms.pattern);

extension DateTimeX on DateTime {
  String beforeAfter(Duration duration) {
    final before = _hm.format(subtract(duration));
    final after = _hm.format(add(duration));
    return '$before - $after';
  }

  String get hm => _hm.format(this);
  String get hms => _hms.format(this);
  String get jms => _jms.format(this);
  String get full => _full.format(this);
}

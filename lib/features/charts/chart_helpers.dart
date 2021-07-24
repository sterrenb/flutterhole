import 'package:flutterhole_web/features/formatting/date_formatting.dart';

String getBottomTitleFromDate(DateTime date) {
  if (date.hour % 2 == 0 && date.minute == 5) {
    return date.subtract(const Duration(minutes: 5)).hm;
  } else {
    return '';
    return date.second.toString();
  }
}

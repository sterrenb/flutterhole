import 'package:flutterhole_web/features/formatting/date_formatting.dart';

/// Converts a [date] into a String.
///
/// Since the Pi-hole timestamps are split in increments of 10 minutes
/// and starting at 5 minutes, we subtract 5 minutes from the original [date].
String getBottomTitleFromDate(DateTime date) {
  if (date.hour % 2 == 0 && date.minute == 5) {
    return date.subtract(const Duration(minutes: 5)).hm;
  } else {
    return '';
  }
}

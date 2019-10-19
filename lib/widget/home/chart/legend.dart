/// Converts a graph value to a String value.
///
/// I am unsure how I got it working, but it does.
String getTimeTitles(value, DateTime time) {
  final rounded = value.toInt();
  final double timeValue =
      ((value / 100) + time.hour + 1) % Duration.hoursPerDay;

  if (rounded % 400 == 0)
    return timeValue.toInt().toString().padLeft(2, '0') + ':00';

  return '';
}

num numFromJson(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.parse(value);
  return -1;
}

DateTime dateTimeFromPiholeString(String key) =>
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(key + '000') ?? 0);

final RegExp _numberRegex = RegExp(r'\d+.\d+');

extension StringExtension on String {
  List<num> getNumbers() {
    if (_numberRegex.hasMatch(this))
      return _numberRegex
          .allMatches(this)
          .map((RegExpMatch match) => num.tryParse(match.group(0)!) ?? -1)
          .toList();
    else
      return [];
  }
}

double celciusToKelvin(double temp) => temp + 273.15;

double celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

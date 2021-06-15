import 'package:flutterhole_web/entities.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat();

extension doubleX on double {
  double _celciusToKelvin(double temp) => temp + 273.15;

  double _celciusToFahrenheit(double temp) => (temp * (9 / 5)) + 32;

  String get temperatureInCelcius => '${toStringAsFixed(1)} °C';

  String get temperatureInFahrenheit =>
      '${_celciusToFahrenheit(this).toStringAsFixed(1)} °F';

  String get temperatureInKelvin =>
      '${_celciusToKelvin(this).toStringAsFixed(1)} °K';

  String temperatureInReading(TemperatureReading reading) {
    switch (reading) {
      case TemperatureReading.celcius:
        return temperatureInCelcius;
      case TemperatureReading.fahrenheit:
        return temperatureInFahrenheit;
      case TemperatureReading.kelvin:
      default:
        return temperatureInKelvin;
    }
  }
}

extension intX on int {
  String secondsOrelse(String orElse) => Intl.plural(this,
      zero: orElse, one: '$this second', other: '$this seconds');
}

final importFormatting = 123;

final _hm = DateFormat.Hm();
final _hms = DateFormat.Hms();
final _jms = DateFormat('H:m:s.S');

extension DateTimeX on DateTime {
  String beforeAfter(Duration duration) {
    final before = _hm.format(subtract(duration));
    final after = _hm.format(add(duration));
    return '$before - $after';
  }

  String get hms => _hms.format(this);
  String get jms => _jms.format(this);
}

extension PiholeApiFailureX on PiholeApiFailure {
  String get title => when(
        notFound: () => 'Not found',
        notAuthenticated: () => 'Not authenticated',
        invalidResponse: (statusCode) => 'Invalid response',
        emptyString: () => 'Empty response',
        emptyList: () => 'Empty response',
        cancelled: () => 'Cancelled',
        timeout: () => 'Timeout',
        unknown: (e) => 'Unknown',
      );

  String get description => title;
}

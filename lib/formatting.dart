import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat();

extension DoubleX on double {
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

extension IntX on int {
  String secondsOrElse(String orElse) => Intl.plural(this,
      zero: orElse, one: '$this second', other: '$this seconds');
}

extension LogLevelX on LogLevel {
  String get readable {
    switch (this) {
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
    }
  }
}

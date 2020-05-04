import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class SettingsException implements Exception {}

abstract class SettingsDataSource {
  Future<PiholeSettings> createPiholeSettings();

  Future<bool> updatePiholeSettings(PiholeSettings piholeSettings);

  Future<bool> deletePiholeSettings(PiholeSettings piholeSettings);

  Future<bool> activatePiholeSettings(PiholeSettings piholeSettings);

  Future<List<PiholeSettings>> fetchAllPiholeSettings();
}

import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class SettingsException implements Exception {}

abstract class SettingsDataSource {
  Future<PiholeSettings> createPiholeSettings();

  Future<void> updatePiholeSettings(PiholeSettings piholeSettings);

  Future<void> deletePiholeSettings(PiholeSettings piholeSettings);

  Future<void> activatePiholeSettings(PiholeSettings piholeSettings);

  Future<List<PiholeSettings>> fetchAllPiholeSettings();
}

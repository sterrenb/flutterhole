import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
@RegisterAs(SettingsDataSource)
class SettingsDataSourceHive implements SettingsDataSource {
  SettingsDataSourceHive([HiveInterface hive])
      : _hive = hive ?? getIt<HiveInterface>();

  final HiveInterface _hive;

  Future<Box> get _piholeBox async {
    final Box box = await _hive.openBox(KStrings.piholeSettingsSubDirectory);

    if (!box.isOpen) throw SettingsException();

    return box;
  }

  Future<int> get _activeIndex async {
    final Box box = await _hive.openBox(KStrings.piholeSettingsActive);

    if (!box.isOpen) throw SettingsException();

    final int index = box.get(KStrings.piholeSettingsActive, defaultValue: -1);

    return index;
  }

  Future<void> _setActiveIndex(int index) async {
    final Box box = await _hive.openBox(KStrings.piholeSettingsActive);

    if (!box.isOpen) throw SettingsException();

    await box.put(KStrings.piholeSettingsActive, index);
  }

  @override
  Future<bool> addPiholeSettings(PiholeSettings settings) async {
    final box = await _piholeBox;

    await box.add(settings.toJson());
    return true;
  }

  @override
  Future<PiholeSettings> createPiholeSettings() async {
    final box = await _piholeBox;
    final piholeSettings = PiholeSettings(title: 'Pihole #${box.length}');

    await box.add(piholeSettings.toJson());
    return piholeSettings;
  }

  @override
  Future<bool> updatePiholeSettings(
    PiholeSettings original,
    PiholeSettings update,
  ) async {
    if (original.title.isEmpty || update.title.isEmpty)
      throw SettingsException();

    final box = await _piholeBox;

    final List<PiholeSettings> all = await fetchAllPiholeSettings();

    final int index = all.indexOf(original);
    if (index < 0) {
      throw PiException.notFound(index);
    }

    await box.putAt(index, update.toJson());

    return true;
  }

  @override
  Future<bool> deletePiholeSettings(PiholeSettings piholeSettings) async {
    final box = await _piholeBox;
    final all = await fetchAllPiholeSettings();

    if (all.contains(piholeSettings)) {
      await box.deleteAt(all.indexOf(piholeSettings));
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> deleteAllSettings() async {
    await _hive.deleteFromDisk();
    return true;
  }

  @override
  Future<List<PiholeSettings>> fetchAllPiholeSettings() async {
    final box = await _piholeBox;

    final list = box.values
        .map<PiholeSettings>(
            (e) => PiholeSettings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return List<PiholeSettings>.from(list);
  }

  @override
  Future<bool> activatePiholeSettings(PiholeSettings piholeSettings) async {
    final List<PiholeSettings> all = await fetchAllPiholeSettings();

    final int index = all.indexOf(piholeSettings);
    if (index < 0) {
      throw PiException.notFound(index);
    }

    await _setActiveIndex(index);

    return true;
  }

  @override
  Future<PiholeSettings> fetchActivePiholeSettings() async {
    final box = await _piholeBox;
    final index = await _activeIndex;

    if (index < 0 || (box?.isEmpty ?? true)) {
      print('no active pihole found in storage, returning default');
      return PiholeSettings();
    }

    final json = box.getAt(index);
    if (json == null) {
      print('no active pihole found at index $index, returning default');
      return PiholeSettings();
    }

    return PiholeSettings.fromJson(Map.from(json));
  }
}

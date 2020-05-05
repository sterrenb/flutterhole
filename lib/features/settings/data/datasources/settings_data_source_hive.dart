import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@prod
@injectable
@RegisterAs(SettingsDataSource)
class SettingsDataSourceHive implements SettingsDataSource {
  SettingsDataSourceHive([HiveInterface hive])
      : _hive = hive ?? getIt<HiveInterface>();

  final HiveInterface _hive;

  Future<Box> get _piholeBox async {
    final Box box = await _hive.openBox(Constants.piholeSettingsSubDirectory);

    if (!box.isOpen) throw SettingsException();

    return box;
  }

  @override
  Future<PiholeSettings> createPiholeSettings() async {
    final box = await _piholeBox;
    final piholeSettings = PiholeSettings(title: 'Pihole #${box.length}');

    await box.add(piholeSettings.toJson());
    return piholeSettings;
  }

  @override
  Future<bool> updatePiholeSettings(PiholeSettings piholeSettings) async {
    if (piholeSettings.title.isEmpty) throw SettingsException();

    final box = await _piholeBox;

    await box.putAt(0, piholeSettings.toJson());

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
  Future<bool> deleteAllSettings()async  {
    await _hive.deleteFromDisk();
    return true;
  }


  @override
  Future<bool> activatePiholeSettings(PiholeSettings piholeSettings) async {
    final box = await _piholeBox;
    await box.putAt(0, piholeSettings.toJson());
    return true;
  }

  @override
  Future<List<PiholeSettings>> fetchAllPiholeSettings() async {
    final box = await _piholeBox;

    final list = box.values
        .map((e) => PiholeSettings.fromJson(e))
        .toList();
    return List<PiholeSettings>.from(list);
  }

  @override
  Future<PiholeSettings> fetchActivePiholeSettings() async {
    final box = await _piholeBox;
    final json = box.getAt(0);
    if (json == null) {
      print('no active pihole found, returning default');
      return PiholeSettings();
    }

    return PiholeSettings.fromJson(json);
  }
}

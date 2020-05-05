import 'package:flutterhole/constants.dart';
import 'package:flutterhole/core/models/exceptions.dart';
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

    await box.put(piholeSettings.title, piholeSettings.toJson());
    return piholeSettings;
  }

  @override
  Future<bool> updatePiholeSettings(PiholeSettings piholeSettings) async {
    if (piholeSettings.title.isEmpty) throw SettingsException();

    final box = await _piholeBox;
    await box.put(piholeSettings.title, piholeSettings.toJson());
    return true;
  }

  @override
  Future<bool> deletePiholeSettings(PiholeSettings piholeSettings) async {
    final box = await _piholeBox;
    await box.delete(piholeSettings.title);
    return true;
  }

  @override
  Future<bool> activatePiholeSettings(PiholeSettings piholeSettings) async {
    final box = await _piholeBox;
    await box.put(Constants.piholeSettingsActive, piholeSettings.title);
    return true;
  }

  @override
  Future<List<PiholeSettings>> fetchAllPiholeSettings() async {
    final box = await _piholeBox;

    final List<PiholeSettings> list = box.values
        .map((e) => PiholeSettings.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return list;
  }

  @override
  Future<PiholeSettings> fetchActivePiholeSettings() async {
    final box = await _piholeBox;
    String title = box.get(Constants.piholeSettingsActive);
    if (title == null) {
      throw NotFoundPiException();
    }

    final List<PiholeSettings> all = await fetchAllPiholeSettings();
    final PiholeSettings active =
        all.firstWhere((element) => element.title == title);
    return active;
  }
}

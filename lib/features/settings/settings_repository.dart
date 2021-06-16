import 'dart:convert';

import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

class SettingsRepository {
  static const _active = 'active';
  static const _userPreferences = 'userPreferences';
  static const _developerPreferences = 'developerPreferences';

  const SettingsRepository(this._sp);

  final SharedPreferences _sp;

  Pi _singlePi(int id) {
    final String? jsonString = _sp.getString(id.toString());
    if (jsonString == null) throw IndexError(id, _sp.getKeys());

    final model = PiModel.fromJson(jsonDecode(jsonString));
    return model.entity;
  }

  List<Pi> allPis() {
    final piIds = _sp.getKeys().map((e) => int.tryParse(e)).whereType<int>();
    final pis = piIds.map((id) => _singlePi(id)).toList();

    if (pis.isEmpty) return [PiModel().entity];
    pis.sort((a, b) => a.id - b.id);
    return pis;
  }

  int activePiId() => _sp.getInt(_active) ?? 0;

  Future<void> setActivePiId(int id) => _sp.setInt(_active, id);

  Future<void> clearAll() => _sp.clear();

  Future<void> clearPiHoles() async {
    final piIds = _sp.getKeys().map((e) => int.tryParse(e)).whereType<int>();
    await Future.wait(piIds.map((e) => _sp.remove(e.toString())));
  }

  Future<void> savePi(Pi pi) async {
    final model = PiModel.fromEntity(pi);
    await _sp.setString(pi.id.toString(), jsonEncode(model));
  }

  UserPreferences getUserPreferences() {
    final String? jsonString = _sp.getString(_userPreferences);
    if (jsonString == null) return UserPreferencesModel().entity;

    final model = UserPreferencesModel.fromJson(jsonDecode(jsonString));
    return model.entity;
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);
    await _sp.setString(_userPreferences, jsonEncode(model));
  }

  DeveloperPreferences getDeveloperPreferences() {
    final String? jsonString = _sp.getString(_developerPreferences);
    if (jsonString == null) return DeveloperPreferencesModel().entity;

    final model = DeveloperPreferencesModel.fromJson(jsonDecode(jsonString));
    return model.entity;
  }

  Future<void> saveDeveloperPreferences(
      DeveloperPreferences preferences) async {
    final model = DeveloperPreferencesModel.fromEntity(preferences);
    await _sp.setString(_developerPreferences, jsonEncode(model));
  }
}

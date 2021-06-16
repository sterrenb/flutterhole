import 'dart:convert';

import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

class SettingsRepository {
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

    if (pis.isEmpty) return [Pi.initial()];
    pis.sort((a, b) => a.id - b.id);
    return pis;
  }

  int activePiId() => _sp.getInt("active") ?? 0;

  Future<void> setActivePiId(int id) => _sp.setInt("active", id);

  Future<void> clearAll() => _sp.clear();

  Future<void> clearPiHoles() async {
    final piIds = _sp.getKeys().map((e) => int.tryParse(e)).whereType<int>();
    await Future.wait(piIds.map((e) => _sp.remove(e.toString())));
  }

  Future<void> savePi(Pi pi) async {
    final model = PiModel.fromEntity(pi);
    await _sp.setString(pi.id.toString(), jsonEncode(model));
  }

  UserPreferences getPreferences() {
    final String? jsonString = _sp.getString("preferences");
    if (jsonString == null) return UserPreferences.initial();

    final model = UserPreferencesModel.fromJson(jsonDecode(jsonString));
    return model.entity;
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);
    await _sp.setString("preferences", jsonEncode(model));
  }
}

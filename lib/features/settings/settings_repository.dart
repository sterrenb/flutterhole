import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/models/settings_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => throw UnimplementedError());

class SettingsRepository {
  static const _active = 'active';
  static const _piHoles = 'piHoles';
  static const _userPreferences = 'userPreferences';

  const SettingsRepository(this._sp);

  final SharedPreferences _sp;

  List<Pi> allPis() {
    final strings = _sp.getStringList(_piHoles);
    if (strings == null) {
      return [PiModel(title: 'default').entity];
    } else {
      return strings
          .map((string) => PiModel.fromJson(jsonDecode(string)).entity)
          .toList();
    }
  }

  int activePiId() {
    return _sp.getInt(_active) ?? 0;
  }

  Future<void> setActivePiId(int id) => _sp.setInt(_active, id);

  Future<void> clearAll() => _sp.clear();

  Future<void> clearPiHoles() async {
    await _sp.remove(_piHoles);
    await setActivePiId(0);
  }

  Future<void> savePi(Pi pi) async {
    List<Pi> all = allPis();

    final currentIndex = all.indexWhere((e) => e.id == pi.id);
    if (currentIndex < 0) {
      all.add(pi);
    } else {
      all[currentIndex] = pi;
    }

    await _sp.setStringList(
        _piHoles, all.map((e) => jsonEncode(PiModel.fromEntity(e))).toList());
  }

  UserPreferences getUserPreferences() {
    final string = _sp.getString(_userPreferences);
    if (string == null) {
      return UserPreferencesModel(
        devMode: kDebugMode,
        useThemeToggle: kDebugMode,
      ).entity;
    } else {
      return UserPreferencesModel.fromJson(jsonDecode(string)).entity;
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);
    await _sp.setString(_userPreferences, jsonEncode(model));
  }
}

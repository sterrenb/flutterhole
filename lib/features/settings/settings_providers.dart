import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/settings/settings_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
        (ref) => SettingsNotifier(ref.read(settingsRepositoryProvider)));

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository)
      : super(SettingsState(
          allPis: _repository.allPis(),
          activeId: _repository.activePiId(),
          dev: true,
        ));

  final SettingsRepository _repository;

  Future<void> reset() async {
    await _repository.clear();
    state = state.copyWith(
      allPis: _repository.allPis(),
      activeId: _repository.activePiId(),
    );
  }

  Future<void> save(Pi pi) async {
    print('saving ${pi.title} ${pi.id}');
    await _repository.savePi(pi);
    await _repository.setActivePiId(pi.id);
    state = state.copyWith(
      allPis: _repository.allPis(),
      activeId: pi.id,
    );
  }

  Future<void> activate(int id) async {
    await _repository.setActivePiId(id);
    state = state.copyWith(activeId: id);
  }
}

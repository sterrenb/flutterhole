import 'package:flutterhole_web/features/entities/logging_entities.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/features/settings/settings_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// final activePiProvider = StateProvider<Pi>((_) => debugPis.first);

// final activePiProvider = Provider<Pi>((ref) {
//   final settings = ref.watch(settingsNotifierProvider);
//   return settings.active;
// });

final allPisProvider = Provider<List<Pi>>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.allPis;
});

// TODO move
final userPreferencesProvider = Provider<UserPreferences>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return settings.userPreferences;
});

final logLevelProvider =
    Provider<LogLevel>((ref) => ref.watch(userPreferencesProvider).logLevel);

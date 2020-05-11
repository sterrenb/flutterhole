import 'package:flutterhole/core/models/exceptions.dart';
import 'package:injectable/injectable.dart';
import 'package:preferences/preferences.dart';

enum Pref {
  string,
  bool,
  int,
  double,
  stringList,
}

class KPrefs {
  KPrefs._();

  static const String useNumbersApi = 'useNumbersApi';

  static const Map<String, Pref> prefs = {
    useNumbersApi: Pref.bool,
  };
}

@prod
@preResolve
@singleton
class PreferenceService {
  @factoryMethod
  static Future<PreferenceService> create() async {
    await PrefService.init();
    return PreferenceService();
  }

  dynamic get(String key) {
    final type = KPrefs.prefs[key];

    if (type == null) throw PiException.notFound();

    switch (type) {
      case Pref.string:
        return PrefService.getString(key);
      case Pref.bool:
        return PrefService.getBool(key);

      case Pref.int:
        return PrefService.getInt(key);

      case Pref.double:
        return PrefService.getDouble(key);

      case Pref.stringList:
        return PrefService.getStringList(key);

      default:
        return PrefService.get(key);
    }
  }
}

import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final allPisProvider = StateProvider<List<Pi>>((_) => debugPis);

final activePiProvider = StateProvider<Pi>((_) => debugPis.first);

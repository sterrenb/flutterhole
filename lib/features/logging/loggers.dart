import 'dart:async';

import 'package:flutterhole_web/entities.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

final loggerProvider = Provider.family<Logger, String>((ref, name) {
  return Logger(name);
});

final logNotifierProvider =
    StateNotifierProvider<LogNotifier, List<LogRecord>>((ref) {
  final log = LogNotifier.fromStream(
      ref.watch(rootLoggerProvider), ref.watch(logStreamProvider.stream));
  // log.listenToStream(ref.watch(logStreamProvider.stream));
  return log;
});

class LogNotifier extends StateNotifier<List<LogRecord>> {
  LogNotifier._(this._root) : super([]);

  factory LogNotifier.fromStream(Logger root, Stream<LogRecord> stream) {
    final log = LogNotifier._(root);
    log.listenToStream(stream);
    return log;
  }

  final Logger _root;
  StreamSubscription<LogRecord>? _subscription;

  @override
  void dispose() {
    print('disposing of logNotifier');
    _subscription?.cancel();
    super.dispose();
  }

  void onData(LogRecord record) {
    // print('got ${record.message}');
    state = [record, ...state];
  }

  // TODO multiple?
  void listenToStream(Stream<LogRecord> stream) {
    _subscription = stream.listen(onData);
    state = [];
  }

  void log(LogCall call) {
    _root.log(call.level.level, call.message, call.error, call.stackTrace);
  }
}

final rootLoggerProvider = Provider<Logger>((ref) {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  return Logger.root;
});

final logStreamProvider = StreamProvider<LogRecord>((ref) async* {
  yield* ref.watch(rootLoggerProvider).onRecord;
});

final logListProvider = FutureProvider<List<LogRecord>>((ref) async {
  return ref.watch(rootLoggerProvider).onRecord.toList();
});

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderBase provider, Object? newValue) {
    print('''

  "{ provider": "${provider.name ?? provider.runtimeType}",
  "  newValue": ${newValue.toString()} }
''');
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutterhole_web/features/entities/settings_entities.dart';
import 'package:flutterhole_web/top_level_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

const importLoggers = null;

extension BuildContextX on BuildContext {
  /// Only works inside [HookWidget]s.
  void log(LogCall call) => this.read(logNotifierProvider.notifier).log(call);
}

final loggerProvider = Provider.family<Logger, String>((ref, name) {
  return Logger(name);
});

final logNotifierProvider =
    StateNotifierProvider.autoDispose<LogNotifier, List<LogRecord>>((ref) {
  print('making logNotifierProvider');
  final log = LogNotifier.fromStream(
      ref.watch(rootLoggerProvider), ref.watch(logStreamProvider.stream));
  // log.listenToStream(ref.watch(logStreamProvider.stream));
  return log;
});

extension LogLevelX on LogLevel {
  Level get level {
    switch (this) {
      case LogLevel.debug:
        return Level.FINE;
      case LogLevel.info:
        return Level.INFO;
      case LogLevel.warning:
        return Level.WARNING;
      case LogLevel.error:
        return Level.SEVERE;
    }
  }
}

class LogNotifier extends StateNotifier<List<LogRecord>> {
  LogNotifier._(this._root) : super([]);

  factory LogNotifier.fromStream(Logger root, Stream<LogRecord> stream) {
    print('LogNotifier from $stream');
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
    if (state.isEmpty) {
      print('adding first log record');
      state = [record, ...state];
      return;
    }

    final x = state.first;
    final y = record;

    print('---');
    print('x == y: ${x == y}');
    print('x.props == y.props: ${x.message == y.message}');
    print('diff: ${x.time.difference(y.time)}');
    print(x);
    print(y);
    print('---');

    if (state.first != record)

      // if (state.isEmpty || state.isNotEmpty && state.first != record) {
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
  final level = ref.watch(logLevelProvider);
  Logger.root.level = level.level;
  print('making root logger @$level');
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  return Logger.root;
});

final logStreamProvider = StreamProvider.autoDispose<LogRecord>((ref) async* {
  yield* ref.watch(rootLoggerProvider).onRecord;
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

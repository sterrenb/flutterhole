import 'package:freezed_annotation/freezed_annotation.dart';

part 'logging_entities.freezed.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

@freezed
class LogCall with _$LogCall {
  LogCall._();

  factory LogCall({
    required String source,
    required LogLevel level,
    required Object message,
    Object? error,
    StackTrace? stackTrace,
  }) = _LogCall;
}

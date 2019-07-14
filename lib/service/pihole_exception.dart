import 'package:equatable/equatable.dart';

class PiholeException extends Equatable implements Exception {
  String _message;
  final dynamic e;

  String get message {
    String message = _message;
    if (e != null) {
      message += e.toString();
    }

    return message;
  }

  static const String defaultMessage = 'unknown Pihole error';

  PiholeException({String message = defaultMessage, this.e})
      : this._message = message,
        super([message, e]);
}

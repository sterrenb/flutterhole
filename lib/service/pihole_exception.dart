import 'package:equatable/equatable.dart';

class PiholeException extends Equatable implements Exception {
  final String message;
  final dynamic e;

  static const String defaultMessage = 'unknown Pihole error';

  PiholeException({this.message = defaultMessage, this.e})
      : super([message, e]);
}

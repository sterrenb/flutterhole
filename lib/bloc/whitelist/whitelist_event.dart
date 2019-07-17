import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WhitelistEvent extends Equatable {
  WhitelistEvent([List props = const []]) : super(props);
}

class FetchWhitelist extends WhitelistEvent {}

class AddToWhitelist extends WhitelistEvent {
  final String domain;

  AddToWhitelist(this.domain) : super([domain]);
}

class RemoveFromWhitelist extends WhitelistEvent {
  final String domain;

  RemoveFromWhitelist(this.domain) : super([domain]);
}

class EditOnWhitelist extends WhitelistEvent {
  final String original;
  final String update;

  EditOnWhitelist(this.original, this.update)
      : super([original, update]);
}

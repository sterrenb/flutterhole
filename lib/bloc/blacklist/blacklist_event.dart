import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlacklistEvent extends Equatable {
  BlacklistEvent([List props = const []]) : super(props);
}

class FetchBlacklist extends BlacklistEvent {}

class AddToBlacklist extends BlacklistEvent {
  final BlacklistItem item;

  AddToBlacklist(this.item) : super([item]);
}

class RemoveFromBlacklist extends BlacklistEvent {
  final BlacklistItem item;

  RemoveFromBlacklist(this.item) : super([item]);
}

class EditOnBlacklist extends BlacklistEvent {
  final BlacklistItem original;
  final BlacklistItem update;

  EditOnBlacklist(this.original, this.update) : super([original, update]);
}

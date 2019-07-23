import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PiholeEvent extends Equatable {
  PiholeEvent([List props = const []]) : super(props);
}

class FetchPiholes extends PiholeEvent {}

class ResetPiholes extends PiholeEvent {}

class AddPihole extends PiholeEvent {
  final Pihole pihole;

  AddPihole(this.pihole) : super([pihole]);
}

class RemovePihole extends PiholeEvent {
  final Pihole pihole;

  RemovePihole(this.pihole) : super([pihole]);
}

class ActivatePihole extends PiholeEvent {
  final Pihole pihole;

  ActivatePihole(this.pihole) : super([pihole]);
}

class UpdatePihole extends PiholeEvent {
  final Pihole original;
  final Pihole update;

  UpdatePihole(this.original, this.update) : super([original, update]);
}

import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PiholeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPiholes extends PiholeEvent {}

class ResetPiholes extends PiholeEvent {}

class AddPihole extends PiholeEvent {
  final Pihole pihole;

  AddPihole(this.pihole);

  @override
  List<Object> get props => [pihole];
}

class RemovePihole extends PiholeEvent {
  final Pihole pihole;

  RemovePihole(this.pihole);

  @override
  List<Object> get props => [pihole];
}

class ActivatePihole extends PiholeEvent {
  final Pihole pihole;

  ActivatePihole(this.pihole);

  @override
  List<Object> get props => [pihole];
}

class UpdatePihole extends PiholeEvent {
  final Pihole original;
  final Pihole update;

  UpdatePihole({
    @required this.original,
    @required this.update,
  });

  @override
  List<Object> get props => [original, update];
}

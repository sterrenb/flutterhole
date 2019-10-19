import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PiholeState extends Equatable {
  @override
  List<Object> get props => [];
}

class PiholeStateEmpty extends PiholeState {}

class PiholeStateLoading extends PiholeState {}

class PiholeStateSuccess extends PiholeState {
  final List<Pihole> all;
  final Pihole active;

  PiholeStateSuccess({this.all, this.active});

  @override
  List<Object> get props => [all, active];
}

class PiholeStateError extends PiholeState {
  final dynamic e;

  PiholeStateError([this.e]);

  @override
  List<Object> get props => [e];
}

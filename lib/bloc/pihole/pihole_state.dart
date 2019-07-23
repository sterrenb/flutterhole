import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:meta/meta.dart';

@immutable
abstract class PiholeState extends Equatable {
  PiholeState([List props = const []]) : super(props);
}

class PiholeStateEmpty extends PiholeState {}

class PiholeStateLoading extends PiholeState {}

class PiholeStateSuccess extends PiholeState {
  final List<Pihole> all;
  final Pihole active;

  PiholeStateSuccess({this.all, this.active}) : super([all, active]);
}

class PiholeStateError extends PiholeState {
  final dynamic e;

  PiholeStateError([this.e]) : super([e]);
}

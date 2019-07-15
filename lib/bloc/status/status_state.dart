import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/model/status.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StatusState extends Equatable {
  StatusState([List props = const []]) : super(props);
}

class StatusStateEmpty extends StatusState {}

class StatusStateLoading extends StatusState {}

class StatusStateSuccess extends StatusState {
  final Status status;

  StatusStateSuccess(this.status) : super([status]);
}

class StatusStateSleeping extends StatusState {
  final Duration durationTotal;
  final Stopwatch stopwatch;

  Duration get durationRemaining => durationTotal - stopwatch.elapsed;

  StatusStateSleeping(this.durationTotal, this.stopwatch)
      : super([durationTotal, stopwatch]);
}

class StatusStateError extends StatusState {
  final PiholeException e;

  StatusStateError({this.e}) : super([e]);
}

import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/model/status.dart';
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
  final Duration durationRemaining;

  StatusStateSleeping(this.durationTotal, this.durationRemaining)
      : super([durationTotal, durationRemaining]);
}

class StatusStateError extends StatusState {
  final String errorMessage;

  StatusStateError({this.errorMessage = 'unknown status error'});
}

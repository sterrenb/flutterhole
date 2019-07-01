import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StatusEvent extends Equatable {
  StatusEvent([List props = const []]) : super(props);
}

class GetStatus extends StatusEvent {}

class EnableStatus extends StatusEvent {}

class DisableStatus extends StatusEvent {}

class SleepStatus extends StatusEvent {
  final Duration duration;

  SleepStatus(this.duration) : super([duration]);
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StatusEvent extends Equatable {
  StatusEvent([List props = const []]) : super(props);
}

class FetchStatus extends StatusEvent {}

class EnableStatus extends StatusEvent {}

class DisableStatus extends StatusEvent {}

class WakeStatus extends StatusEvent {}

class SleepStatus extends StatusEvent {
  final Duration duration;

  SleepStatus(this.duration) : super([duration]);
}

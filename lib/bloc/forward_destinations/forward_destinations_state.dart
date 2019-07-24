import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/forward_destinations.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ForwardDestinationsState extends Equatable {
  ForwardDestinationsState([List props = const []]) : super(props);
}

class ForwardDestinationsStateEmpty extends ForwardDestinationsState {}

class ForwardDestinationsStateLoading extends ForwardDestinationsState {}

class ForwardDestinationsStateSuccess extends ForwardDestinationsState {
  final ForwardDestinations forwardDestinations;

  ForwardDestinationsStateSuccess(this.forwardDestinations)
      : super([forwardDestinations]);
}

class ForwardDestinationsStateError extends ForwardDestinationsState {
  final PiholeException e;

  ForwardDestinationsStateError({this.e}) : super([e]);
}

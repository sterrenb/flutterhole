import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ForwardDestinationsEvent extends Equatable {
  ForwardDestinationsEvent([List props = const []]) : super(props);
}

class FetchForwardDestinations extends ForwardDestinationsEvent {}

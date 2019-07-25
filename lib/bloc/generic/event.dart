import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GenericEvent extends Equatable {
  GenericEvent([List props = const []]) : super(props);
}

class Fetch extends GenericEvent {}

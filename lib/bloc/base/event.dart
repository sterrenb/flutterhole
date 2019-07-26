import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlocEvent extends Equatable {
  BlocEvent([List props = const []]) : super(props);
}

class Fetch extends BlocEvent {}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlocEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch extends BlocEvent {}

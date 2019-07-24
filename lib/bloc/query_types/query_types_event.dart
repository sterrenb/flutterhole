import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QueryTypesEvent extends Equatable {
  QueryTypesEvent([List props = const []]) : super(props);
}

class FetchQueryTypes extends QueryTypesEvent {}

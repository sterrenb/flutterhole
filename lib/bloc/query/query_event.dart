import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QueryEvent extends Equatable {
  QueryEvent([List props = const []]) : super(props);
}

class FetchQueries extends QueryEvent {}

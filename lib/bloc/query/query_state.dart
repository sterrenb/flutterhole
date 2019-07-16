import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/model/query.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QueryState extends Equatable {
  QueryState([List props = const []]) : super(props);
}

class QueryStateEmpty extends QueryState {}

class QueryStateLoading extends QueryState {
  final List<Query> cache;

  QueryStateLoading({this.cache}) : super([cache]);
}

class QueryStateSuccess extends QueryState {
  final List<Query> queries;

  QueryStateSuccess(this.queries) : super([Query]);
}

class QueryStateError extends QueryState {
  final PiholeException e;

  QueryStateError({this.e}) : super([e]);
}

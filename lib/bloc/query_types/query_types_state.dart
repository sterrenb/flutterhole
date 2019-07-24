import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class QueryTypesState extends Equatable {
  QueryTypesState([List props = const []]) : super(props);
}

class QueryTypesStateEmpty extends QueryTypesState {}

class QueryTypesStateLoading extends QueryTypesState {}

class QueryTypesStateSuccess extends QueryTypesState {
  final QueryTypes queryTypes;

  QueryTypesStateSuccess(this.queryTypes) : super([queryTypes]);
}

class QueryTypesStateError extends QueryTypesState {
  final PiholeException e;

  QueryTypesStateError({this.e}) : super([e]);
}

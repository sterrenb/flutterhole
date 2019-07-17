import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SummaryState extends Equatable {
  SummaryState([List props = const []]) : super(props);
}

class SummaryStateEmpty extends SummaryState {}

class SummaryStateLoading extends SummaryState {}

class SummaryStateSuccess extends SummaryState {
  final Summary summary;

  SummaryStateSuccess(this.summary) : super([summary]);
}

class SummaryStateError extends SummaryState {
  final PiholeException e;

  SummaryStateError({this.e}) : super([e]);
}

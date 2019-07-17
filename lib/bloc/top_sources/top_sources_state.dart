import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TopSourcesState extends Equatable {
  TopSourcesState([List props = const []]) : super(props);
}

class TopSourcesStateEmpty extends TopSourcesState {}

class TopSourcesStateLoading extends TopSourcesState {}

class TopSourcesStateSuccess extends TopSourcesState {
  final TopSources topSources;

  TopSourcesStateSuccess(this.topSources) : super([topSources]);
}

class TopSourcesStateError extends TopSourcesState {
  final PiholeException e;

  TopSourcesStateError({this.e}) : super([e]);
}

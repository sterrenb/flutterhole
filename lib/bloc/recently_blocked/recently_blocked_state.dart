import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RecentlyBlockedState extends Equatable {
  RecentlyBlockedState([List props = const []]) : super(props);
}

class RecentlyBlockedStateEmpty extends RecentlyBlockedState {}

class RecentlyBlockedStateLoading extends RecentlyBlockedState {
  final Map<String, int> cache;

  RecentlyBlockedStateLoading({this.cache}) : super([cache]);
}

class RecentlyBlockedStateSuccess extends RecentlyBlockedState {
  final Map<String, int> cache;

  RecentlyBlockedStateSuccess(this.cache) : super([cache]);
}

class RecentlyBlockedStateError extends RecentlyBlockedState {
  final PiholeException e;

  RecentlyBlockedStateError({this.e}) : super([e]);
}

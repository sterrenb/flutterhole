import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class RecentlyBlockedEvent extends Equatable {
  RecentlyBlockedEvent([List props = const []]) : super(props);
}

class FetchRecentlyBlocked extends RecentlyBlockedEvent {}

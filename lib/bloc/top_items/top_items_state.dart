import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/top_items.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TopItemsState extends Equatable {
  TopItemsState([List props = const []]) : super(props);
}

class TopItemsStateEmpty extends TopItemsState {}

class TopItemsStateLoading extends TopItemsState {}

class TopItemsStateSuccess extends TopItemsState {
  final TopItems topItems;

  TopItemsStateSuccess(this.topItems) : super([topItems]);
}

class TopItemsStateError extends TopItemsState {
  final PiholeException e;

  TopItemsStateError({this.e}) : super([e]);
}

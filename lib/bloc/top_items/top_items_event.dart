import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TopItemsEvent extends Equatable {
  TopItemsEvent([List props = const []]) : super(props);
}

class FetchTopItems extends TopItemsEvent {}

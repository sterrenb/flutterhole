import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TopSourcesEvent extends Equatable {
  TopSourcesEvent([List props = const []]) : super(props);
}

class FetchTopSources extends TopSourcesEvent {}

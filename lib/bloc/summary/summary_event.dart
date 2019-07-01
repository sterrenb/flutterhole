import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SummaryEvent extends Equatable {
  SummaryEvent([List props = const []]) : super(props);
}

class FetchSummary extends SummaryEvent {}

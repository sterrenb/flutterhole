import 'package:equatable/equatable.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class GenericState<T> extends Equatable {
  GenericState([List props = const []]) : super(props);
}

class GenericStateEmpty<T> extends GenericState<T> {}

class GenericStateLoading<T> extends GenericState<T> {}

class GenericStateSuccess<T> extends GenericState {
  final T generic;

  GenericStateSuccess(this.generic) : super([generic]);
}

class GenericStateError<T> extends GenericState<T> {
  final PiholeException e;

  GenericStateError([this.e]) : super([e]);
}

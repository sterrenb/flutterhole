import 'package:equatable/equatable.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlocState<T> extends Equatable {
  BlocState([List props = const []]) : super(props);
}

class BlocStateEmpty<T> extends BlocState<T> {}

class BlocStateLoading<T> extends BlocState<T> {
//  final T data;
//
//  bool get hasCache => data != null;
//
//  BlocStateLoading([this.data]) : super([data]);
}

class BlocStateSuccess<T> extends BlocState {
  final T data;

  BlocStateSuccess(this.data) : super([data]);
}

class BlocStateError<T> extends BlocState<T> {
  final PiholeException e;

  BlocStateError([this.e]) : super([e]);
}

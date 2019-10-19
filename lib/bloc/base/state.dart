import 'package:equatable/equatable.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlocState<T> extends Equatable {
  @override
  List<Object> get props => [];
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

  BlocStateSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class BlocStateError<T> extends BlocState<T> {
  final PiholeException e;

  BlocStateError([this.e]);

  @override
  List<Object> get props => [e];
}

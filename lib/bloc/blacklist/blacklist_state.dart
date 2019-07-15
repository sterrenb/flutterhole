import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class BlacklistState extends Equatable {
  BlacklistState([List props = const []]) : super(props);
}

class BlacklistStateEmpty extends BlacklistState {}

class BlacklistStateLoading extends BlacklistState {
  final Blacklist cache;

  BlacklistStateLoading({this.cache}) : super([cache]);
}

class BlacklistStateSuccess extends BlacklistState {
  final Blacklist cache;

  BlacklistStateSuccess(this.cache) : super([cache]);
}

class BlacklistStateError extends BlacklistState {
  final PiholeException e;

  BlacklistStateError({this.e}) : super([e]);
}

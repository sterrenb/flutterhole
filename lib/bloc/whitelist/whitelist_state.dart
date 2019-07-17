import 'package:equatable/equatable.dart';
import 'package:flutterhole/model/whitelist.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:meta/meta.dart';

@immutable
abstract class WhitelistState extends Equatable {
  WhitelistState([List props = const []]) : super(props);
}

class WhitelistStateEmpty extends WhitelistState {}

class WhitelistStateLoading extends WhitelistState {
  final Whitelist cache;

  WhitelistStateLoading({this.cache}) : super([cache]);
}

class WhitelistStateSuccess extends WhitelistState {
  final Whitelist whitelist;

  WhitelistStateSuccess(this.whitelist) : super([whitelist]);
}

class WhitelistStateError extends WhitelistState {
  final PiholeException e;

  WhitelistStateError({this.e}) : super([e]);
}

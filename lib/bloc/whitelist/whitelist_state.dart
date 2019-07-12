import 'package:equatable/equatable.dart';
import 'package:flutterhole_again/model/whitelist.dart';
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
  final Whitelist cache;

  WhitelistStateSuccess(this.cache) : super([cache]);
}

class WhitelistStateError extends WhitelistState {
  final String errorMessage;

  WhitelistStateError({this.errorMessage = 'whitelist error'})
      : super([errorMessage]);
}

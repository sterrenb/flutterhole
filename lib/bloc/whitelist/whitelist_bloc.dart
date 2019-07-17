import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/whitelist/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class WhitelistBloc extends Bloc<WhitelistEvent, WhitelistState> {
  final WhitelistRepository whitelistRepository;

  WhitelistBloc(this.whitelistRepository);

  @override
  WhitelistState get initialState => WhitelistStateEmpty();

  @override
  Stream<WhitelistState> mapEventToState(
    WhitelistEvent event,
  ) async* {
    yield WhitelistStateLoading(cache: whitelistRepository.cache);
    if (event is FetchWhitelist) yield* _fetch();
    if (event is AddToWhitelist) yield* _add(event.domain);
    if (event is RemoveFromWhitelist) yield* _remove(event.domain);
    if (event is EditOnWhitelist) yield* _edit(event.original, event.update);
  }

  Stream<WhitelistState> _fetch() async* {
    try {
      final whitelist = await whitelistRepository.getWhitelist();
      yield WhitelistStateSuccess(whitelist);
    } on PiholeException catch (e) {
      yield WhitelistStateError(e: e);
    }
  }

  Stream<WhitelistState> _add(String domain) async* {
    try {
      await whitelistRepository.addToWhitelist(domain);
      yield WhitelistStateSuccess(whitelistRepository.cache);
    } on PiholeException catch (e) {
      yield WhitelistStateError(e: e);
    }
  }

  Stream<WhitelistState> _remove(String domain) async* {
    try {
      await whitelistRepository.removeFromWhitelist(domain);
      yield WhitelistStateSuccess(whitelistRepository.cache);
    } on PiholeException catch (e) {
      yield WhitelistStateError(e: e);
    }
  }

  Stream<WhitelistState> _edit(String original, String update) async* {
    try {
      final whitelist =
      await whitelistRepository.editOnWhitelist(original, update);
      yield WhitelistStateSuccess(whitelist);
    } on PiholeException catch (e) {
      yield WhitelistStateError(e: e);
    }
  }
}

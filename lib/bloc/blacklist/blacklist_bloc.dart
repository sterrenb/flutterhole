import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';

import 'bloc.dart';

class BlacklistBloc extends Bloc<BlacklistEvent, BlacklistState> {
  final BlacklistRepository blacklistRepository;

  BlacklistBloc(this.blacklistRepository);

  @override
  BlacklistState get initialState => BlacklistStateEmpty();

  @override
  Stream<BlacklistState> mapEventToState(
    BlacklistEvent event,
  ) async* {
    yield BlacklistStateLoading(cache: blacklistRepository.cache);
    if (event is FetchBlacklist) yield* _fetch();
    if (event is AddToBlacklist) yield* _add(event.item);
    if (event is RemoveFromBlacklist) yield* _remove(event.item);
    if (event is EditOnBlacklist) yield* _edit(event.original, event.update);
  }

  Stream<BlacklistState> _fetch() async* {
    try {
      final blacklist = await blacklistRepository.getBlacklist();
      yield BlacklistStateSuccess(blacklist);
    } on PiholeException catch (e) {
      yield BlacklistStateError(e: e);
    }
  }

  Stream<BlacklistState> _add(BlacklistItem item) async* {
    try {
      await blacklistRepository.addToBlacklist(item);
      yield BlacklistStateSuccess(blacklistRepository.cache);
    } on PiholeException catch (e) {
      yield BlacklistStateError(e: e);
    }
  }

  Stream<BlacklistState> _remove(BlacklistItem item) async* {
    try {
      await blacklistRepository.removeFromBlacklist(item);
      yield BlacklistStateSuccess(blacklistRepository.cache);
    } on PiholeException catch (e) {
      yield BlacklistStateError(e: e);
    }
  }

  Stream<BlacklistState> _edit(
      BlacklistItem original, BlacklistItem update) async* {
    try {
      await blacklistRepository.editOnBlacklist(original, update);
      yield BlacklistStateSuccess(blacklistRepository.cache);
    } on PiholeException catch (e) {
      yield BlacklistStateError(e: e);
    }
  }
}

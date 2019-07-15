import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/repository/recently_blocked_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';

import 'recently_blocked_event.dart';
import 'recently_blocked_state.dart';

class RecentlyBlockedBloc
    extends Bloc<RecentlyBlockedEvent, RecentlyBlockedState> {
  final RecentlyBlockedRepository recentlyBlockedRepository;

  RecentlyBlockedBloc(this.recentlyBlockedRepository);

  @override
  RecentlyBlockedState get initialState => RecentlyBlockedStateEmpty();

  @override
  Stream<RecentlyBlockedState> mapEventToState(
    RecentlyBlockedEvent event,
  ) async* {
    yield RecentlyBlockedStateLoading(cache: recentlyBlockedRepository.cache);
    if (event is FetchRecentlyBlocked) yield* _fetch();
  }

  Stream<RecentlyBlockedState> _fetch() async* {
    try {
      await recentlyBlockedRepository.getRecentlyBlocked();
      yield RecentlyBlockedStateSuccess(recentlyBlockedRepository.cache);
    } on PiholeException catch (e) {
      yield RecentlyBlockedStateError(e: e);
    }
  }
}

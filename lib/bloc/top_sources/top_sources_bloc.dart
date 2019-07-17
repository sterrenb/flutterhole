import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/top_sources/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class TopSourcesBloc extends Bloc<TopSourcesEvent, TopSourcesState> {
  final TopSourcesRepository topSourcesRepository;

  TopSourcesBloc(this.topSourcesRepository);

  @override
  TopSourcesState get initialState => TopSourcesStateEmpty();

  @override
  Stream<TopSourcesState> mapEventToState(
    TopSourcesEvent event,
  ) async* {
    if (event is FetchTopSources) yield* _fetch();
  }

  Stream<TopSourcesState> _fetch() async* {
    yield TopSourcesStateLoading();
    try {
      final topSources = await topSourcesRepository.getTopSources();
      yield TopSourcesStateSuccess(topSources);
    } on PiholeException catch (e) {
      yield TopSourcesStateError(e: e);
    }
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/top_items/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class TopItemsBloc extends Bloc<TopItemsEvent, TopItemsState> {
  final TopItemsRepository topItemsRepository;

  TopItemsBloc(this.topItemsRepository);

  @override
  TopItemsState get initialState => TopItemsStateEmpty();

  @override
  Stream<TopItemsState> mapEventToState(
    TopItemsEvent event,
  ) async* {
    if (event is FetchTopItems) yield* _fetch();
  }

  Stream<TopItemsState> _fetch() async* {
    yield TopItemsStateLoading();
    try {
      final topItems = await topItemsRepository.getTopItems();
      yield TopItemsStateSuccess(topItems);
    } on PiholeException catch (e) {
      yield TopItemsStateError(e: e);
    }
  }
}

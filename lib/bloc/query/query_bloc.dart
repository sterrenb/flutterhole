import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/query/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class QueryBloc extends Bloc<QueryEvent, QueryState> {
  final QueryRepository queryRepository;

  QueryBloc(this.queryRepository);

  @override
  QueryState get initialState => QueryStateEmpty();

  @override
  Stream<QueryState> mapEventToState(
    QueryEvent event,
  ) async* {
    yield QueryStateLoading(cache: queryRepository.cache);
    if (event is FetchQueries) yield* _fetch();
  }

  Stream<QueryState> _fetch() async* {
    try {
      final cache = await queryRepository.getQueries();
      yield QueryStateSuccess(cache);
    } on PiholeException catch (e) {
      yield QueryStateError(e: e);
    }
  }
}

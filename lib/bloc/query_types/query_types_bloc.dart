import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/query_types/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class QueryTypesBloc extends Bloc<QueryTypesEvent, QueryTypesState> {
  final QueryTypesRepository queryTypesRepository;

  QueryTypesBloc(this.queryTypesRepository);

  @override
  QueryTypesState get initialState => QueryTypesStateEmpty();

  @override
  Stream<QueryTypesState> mapEventToState(
    QueryTypesEvent event,
  ) async* {
    if (event is FetchQueryTypes) yield* _fetch();
  }

  Stream<QueryTypesState> _fetch() async* {
    yield QueryTypesStateLoading();
    try {
      final queryTypes = await queryTypesRepository.getQueryTypes();
      print('bloc: queryTypes: ${queryTypes.queryTypes}');
      yield QueryTypesStateSuccess(queryTypes);
    } on PiholeException catch (e) {
      yield QueryTypesStateError(e: e);
    }
  }
}

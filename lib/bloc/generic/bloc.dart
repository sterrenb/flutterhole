import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/generic/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

import 'repository.dart';

export 'event.dart';
export 'state.dart';

abstract class GenericBloc<T> extends Bloc<GenericEvent, GenericState> {
  final GenericRepository<T> genericRepository;

  GenericBloc(this.genericRepository);

  @override
  GenericState<T> get initialState => GenericStateEmpty<T>();

  @override
  Stream<GenericState> mapEventToState(
    GenericEvent event,
  ) async* {
    if (event is Fetch) yield* fetch();
  }

  Stream<GenericState> fetch() async* {
    yield GenericStateLoading<T>();
    try {
      final generic = await genericRepository.get();
      yield GenericStateSuccess<T>(generic);
    } on PiholeException catch (e) {
      yield GenericStateError<T>(e);
    }
  }
}

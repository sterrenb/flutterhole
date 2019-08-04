import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

import 'repository.dart';

export 'event.dart';
export 'state.dart';

abstract class BaseBloc<T> extends Bloc<BlocEvent, BlocState> {
  final BaseRepository<T> repository;

  bool get hasCache => cache != null;

  T cache;

  BaseBloc(this.repository);

  @override
  BlocState<T> get initialState => BlocStateEmpty<T>();

  @override
  Stream<BlocState> mapEventToState(BlocEvent event,
  ) async* {
    if (event is Fetch) yield* fetch();
  }

  Stream<BlocState> fetch() async* {
    yield BlocStateLoading<T>();
    try {
      cache = await repository.get();
      yield BlocStateSuccess<T>(cache);
    } on PiholeException catch (e) {
      yield BlocStateError<T>(e);
    }
  }
}

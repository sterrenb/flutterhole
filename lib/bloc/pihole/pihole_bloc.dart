import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/model/pihole.dart';

import './bloc.dart';

class PiholeBloc extends Bloc<PiholeEvent, PiholeState> {
  final PiholeRepository repository;

  PiholeBloc(this.repository);

  @override
  PiholeState get initialState => PiholeStateEmpty();

  @override
  Stream<PiholeState> mapEventToState(
    PiholeEvent event,
  ) async* {
//    await Future.delayed(Duration(seconds: 2));
    yield PiholeStateLoading();
    if (event is FetchPiholes) yield* _fetch();
    if (event is ResetPiholes) yield* _reset();
    if (event is AddPihole) yield* _add(event.pihole);
    if (event is RemovePihole) yield* _remove(event.pihole);
    if (event is ActivatePihole) yield* _activate(event.pihole);
    if (event is UpdatePihole) yield* _update(event.original, event.update);
  }

  Stream<PiholeState> _fetch() async* {
    yield PiholeStateLoading();
    try {
      await repository.refresh();
      yield PiholeStateSuccess(
          all: repository.getPiholes(), active: repository.active());
    } catch (e) {
      yield PiholeStateError(e);
    }
  }

  Stream<PiholeState> _reset() async* {
    yield PiholeStateLoading();
    try {
      await repository.reset();
      yield PiholeStateSuccess(
          all: repository.getPiholes(), active: repository.active());
    } catch (e) {
      yield PiholeStateError(e);
    }
  }

  Stream<PiholeState> _add(Pihole pihole) async* {
    try {
      await repository.add(pihole);
      yield PiholeStateSuccess(
          all: repository.getPiholes(), active: repository.active());
    } catch (e) {
      yield PiholeStateError(e);
    }
  }

  Stream<PiholeState> _remove(Pihole pihole) async* {
    try {
      await repository.remove(pihole);
      yield PiholeStateSuccess(
          all: repository.getPiholes(), active: repository.active());
    } catch (e) {
      yield PiholeStateError(e);
    }
  }

  Stream<PiholeState> _activate(Pihole pihole) async* {
    try {
      await repository.activate(pihole);
      final active = repository.active();
      yield PiholeStateSuccess(all: repository.getPiholes(), active: active);
    } catch (e) {
      yield PiholeStateError(e);
    }
  }

  Stream<PiholeState> _update(Pihole original, Pihole update) async* {
    try {
      await repository.update(original, update);
      yield PiholeStateSuccess(
          all: repository.getPiholes(), active: repository.active());
    } catch (e) {
      yield PiholeStateError(e);
    }
  }
}

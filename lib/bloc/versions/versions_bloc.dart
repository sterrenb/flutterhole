import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/versions/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class VersionsBloc extends Bloc<VersionsEvent, VersionsState> {
  final VersionsRepository versionsRepository;

  VersionsBloc(this.versionsRepository);

  @override
  VersionsState get initialState => VersionsStateEmpty();

  @override
  Stream<VersionsState> mapEventToState(
    VersionsEvent event,
  ) async* {
    if (event is FetchVersions) yield* _fetch(event.pihole);
  }

  Stream<VersionsState> _fetch([Pihole pihole]) async* {
    yield VersionsStateLoading();
    try {
      final versions = await versionsRepository.getVersions(pihole);
      yield VersionsStateSuccess(versions);
    } on PiholeException catch (e) {
      yield VersionsStateError(e: e);
    }
  }
}

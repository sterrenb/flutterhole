import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/bloc/status/status_event.dart';
import 'package:flutterhole_again/bloc/status/status_state.dart';
import 'package:flutterhole_again/repository/status_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';


class StatusBloc extends Bloc<StatusEvent, StatusState> {
  final StatusRepository statusRepository;

  StatusBloc(this.statusRepository);

  @override
  StatusState get initialState => StatusStateEmpty();

  @override
  Stream<StatusState> mapEventToState(
    StatusEvent event,
  ) async* {
    if (event is FetchStatus) yield* _fetch();
    if (event is EnableStatus) yield* _enable();
    if (event is DisableStatus) yield* _disable();
    if (event is SleepStatus) yield* _sleep(event.duration);
  }

  Stream<StatusState> _fetch() async* {
    yield StatusStateLoading();
    try {
      final status = await statusRepository.getStatus();
      yield StatusStateSuccess(status);
    } on PiholeException catch (e) {
      yield StatusStateError(errorMessage: e.message);
    }
  }

  Stream<StatusState> _enable() async* {
    yield StatusStateLoading();
    try {
      final status = await statusRepository.enable();
      yield StatusStateSuccess(status);
    } on PiholeException catch (e) {
      yield StatusStateError(errorMessage: e.message);
    }
  }

  Stream<StatusState> _disable() async* {
    yield StatusStateLoading();
    try {
      final status = await statusRepository.disable();
      yield StatusStateSuccess(status);
    } on PiholeException catch (e) {
      yield StatusStateError(errorMessage: e.message);
    }
  }

  Stream<StatusState> _sleep(Duration duration) async* {
    yield StatusStateLoading();
    try {
      await statusRepository.sleep(duration);
      if (statusRepository.elapsed != null) {
        yield StatusStateSleeping(
            duration, duration - statusRepository.elapsed);
      } else {
        yield StatusStateSleeping(duration, duration);
      }
    } on PiholeException catch (e) {
      yield StatusStateError(errorMessage: e.message);
    }
  }
}

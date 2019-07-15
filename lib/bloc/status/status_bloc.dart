import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/bloc/status/status_event.dart';
import 'package:flutterhole_again/bloc/status/status_state.dart';
import 'package:flutterhole_again/model/status.dart';
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
    statusRepository.cancelSleep();
    if (event is WakeStatus) yield* _wake();
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
      yield StatusStateError(e: e);
    }
  }

  Stream<StatusState> _enable() async* {
    yield StatusStateLoading();
    try {
      final status = await statusRepository.enable();
      yield StatusStateSuccess(status);
    } on PiholeException catch (e) {
      yield StatusStateError(e: e);
    }
  }

  Stream<StatusState> _disable() async* {
    yield StatusStateLoading();
    try {
      final status = await statusRepository.disable();
      yield StatusStateSuccess(status);
    } on PiholeException catch (e) {
      yield StatusStateError(e: e);
    }
  }

  /// Optimistically assumes that the sleep timer has run out on the Pi-hole
  Stream<StatusState> _wake() async* {
    yield StatusStateSuccess(Status(enabled: true));
  }

  Stream<StatusState> _sleep(Duration duration) async* {
    yield StatusStateLoading();
    try {
      await statusRepository.sleep(duration, () => this.dispatch(WakeStatus()));
      if (statusRepository.stopwatch == null) {
        yield StatusStateError(e: PiholeException());
      } else {
        yield StatusStateSleeping(duration, statusRepository.stopwatch);
      }
    } on PiholeException catch (e) {
      yield StatusStateError(e: e);
    }
  }
}

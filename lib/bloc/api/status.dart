import 'dart:async';

import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class StatusStateSleeping extends BlocState<Status> {
  final Duration durationTotal;
  final Stopwatch stopwatch;

  Duration get durationRemaining => durationTotal - stopwatch.elapsed;

  StatusStateSleeping(this.durationTotal, this.stopwatch)
      : super([durationTotal, stopwatch]);
}

class EnableStatus extends BlocEvent {}

class DisableStatus extends BlocEvent {}

class WakeStatus extends BlocEvent {}

class SleepStatus extends BlocEvent {
  final Duration duration;

  SleepStatus(this.duration) : super([duration]);
}

class StatusBloc extends BaseBloc<Status> {
  final StatusRepository repository;

  StatusBloc(this.repository) : super(repository);

  Stream<BlocState> _enable() async* {
    yield BlocStateLoading<Status>();
    try {
      final status = await repository.enable();
      yield BlocStateSuccess<Status>(status);
    } on PiholeException catch (e) {
      yield BlocStateError<Status>(e);
    }
  }

  Stream<BlocState> _disable() async* {
    yield BlocStateLoading<Status>();
    try {
      final status = await repository.disable();
      yield BlocStateSuccess<Status>(status);
    } on PiholeException catch (e) {
      yield BlocStateError<Status>(e);
    }
  }

  /// Optimistically assumes that the sleep timer has run out on the Pi-hole
  Stream<BlocState> _wake() async* {
    yield BlocStateSuccess<Status>(Status(enabled: true));
  }

  Stream<BlocState> _sleep(Duration duration) async* {
    yield BlocStateLoading<Status>();
    try {
      await repository.sleep(duration, () => this.dispatch(WakeStatus()));
      if (repository.stopwatch == null) {
        yield BlocStateError<Status>(PiholeException());
      } else {
        yield StatusStateSleeping(duration, repository.stopwatch);
      }
    } on PiholeException catch (e) {
      yield BlocStateError<Status>(e);
    }
  }

  @override
  Stream<BlocState> mapEventToState(
    BlocEvent event,
  ) async* {
    yield BlocStateLoading<Status>();
    repository.cancelSleep();
    if (event is Fetch) yield* fetch();
    if (event is WakeStatus) yield* _wake();
    if (event is EnableStatus) yield* _enable();
    if (event is DisableStatus) yield* _disable();
    if (event is SleepStatus) yield* _sleep(event.duration);
  }
}

class StatusRepository extends BaseRepository<Status> {
  StatusRepository(this.client) : super(client);
  final PiholeClient client;
  final Stopwatch _stopwatch = Stopwatch();

  Stopwatch get stopwatch => _stopwatch;

  Timer _timer;

  Duration get elapsed => _stopwatch.elapsed;

  @override
  Future<Status> get() async {
    return client.fetchStatus();
  }

  Future<Status> enable() async {
    final status = await client.enable();
    _stopwatch.stop();
    _stopwatch.reset();
    return status;
  }

  Future<Status> disable() async {
    return client.disable();
  }

  Future<Status> sleep(Duration duration, void callback()) async {
    final status = await client.disable(duration);
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer(duration, callback);
    return status;
  }

  void cancelSleep() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
  }
}

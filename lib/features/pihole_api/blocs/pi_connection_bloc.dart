import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/connection_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'pi_connection_bloc.freezed.dart';

@freezed
abstract class PiConnectionState with _$PiConnectionState {
  const factory PiConnectionState.initial() = PiConnectionStateInitial;

  const factory PiConnectionState.loading() = PiConnectionStateLoading;

  const factory PiConnectionState.failure(Failure failure) =
  PiConnectionStateFailure;

  const factory PiConnectionState.active(PiholeSettings settings,
      ToggleStatus toggleStatus) =
      PiConnectionStateActive;

  const factory PiConnectionState.sleeping(PiholeSettings settings,
      DateTime start,
      Duration duration,) = PiConnectionStateSleeping;
}

@freezed
abstract class PiConnectionEvent with _$PiConnectionEvent {
  const factory PiConnectionEvent.ping() = PiConnectionEventPing;

  const factory PiConnectionEvent.enable() = PiConnectionEventEnable;

  const factory PiConnectionEvent.disable() = PiConnectionEventDisable;

  const factory PiConnectionEvent.sleep(Duration duration, DateTime now) =
  PiConnectionEventSleep;
}

typedef Future<Either<Failure, ToggleStatus>> ConnectionFunction(
    PiholeSettings piholeSettings);

@singleton
class PiConnectionBloc extends Bloc<PiConnectionEvent, PiConnectionState> {
  PiConnectionBloc([
    ConnectionRepository connectionRepository,
    SettingsRepository settingsRepository,
  ])  : _connectionRepository =
            connectionRepository ?? getIt<ConnectionRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ConnectionRepository _connectionRepository;
  final SettingsRepository _settingsRepository;

  @override
  PiConnectionState get initialState => PiConnectionState.initial();

  /// Wrapper for accessing [ConnectionRepository] methods with known signature.
  Stream<PiConnectionState> _do(ConnectionFunction f) async* {
    yield PiConnectionState.loading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold((Failure failure) async* {
      yield PiConnectionState.failure(failure);
    }, (PiholeSettings settings) async* {
      final Either<Failure, ToggleStatus> statusResult = await f(settings);

      yield* statusResult.fold((Failure failure) async* {
        yield PiConnectionState.failure(failure);
      }, (status) async* {
        yield PiConnectionState.active(settings, status);
      });
    });
  }

  Stream<PiConnectionState> _ping() => _do(_connectionRepository.pingPihole);

  Stream<PiConnectionState> _enable() =>
      _do(_connectionRepository.enablePihole);

  Stream<PiConnectionState> _disable() =>
      _do(_connectionRepository.disablePihole);

  Stream<PiConnectionState> _sleep(Duration duration, DateTime now) async* {
    yield PiConnectionState.loading();

    final Either<Failure, PiholeSettings> active =
    await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold((Failure failure) async* {
      yield PiConnectionState.failure(failure);
    }, (PiholeSettings settings) async* {
      final Either<Failure, ToggleStatus> statusResult =
      await _connectionRepository.sleepPihole(settings, duration);

      yield* statusResult.fold((Failure failure) async* {
        yield PiConnectionState.failure(failure);
      }, (status) async* {
        yield PiConnectionState.sleeping(
          settings,
          now,
          duration,
        );

        // Thank you to felix <3
        // https://github.com/felangel/bloc/issues/1171#issuecomment-628685175
        Future.delayed(duration).whenComplete(() {
          add(PiConnectionEvent.ping());
        });
      });
    });
  }

  @override
  Stream<PiConnectionState> mapEventToState(
    PiConnectionEvent event,
  ) =>
      event.when(
        ping: () => _ping(),
        enable: () => _enable(),
        disable: () => _disable(),
        sleep: (Duration duration, DateTime now) => _sleep(duration, now),
      );
}

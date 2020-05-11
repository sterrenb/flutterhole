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

part 'connection_bloc.freezed.dart';

@freezed
abstract class ConnectionState with _$ConnectionState {
  const factory ConnectionState.initial() = ConnectionStateInitial;

  const factory ConnectionState.loading() = ConnectionStateLoading;

  const factory ConnectionState.failure(Failure failure) = ConnectionFailure;

  const factory ConnectionState.active(ToggleStatus toggleStatus) =
      ConnectionStateActive;
}

@freezed
abstract class ConnectionEvent with _$ConnectionEvent {
  const factory ConnectionEvent.ping() = ConnectionEventPing;

  const factory ConnectionEvent.enable() = ConnectionEventEnable;

  const factory ConnectionEvent.disable() = ConnectionEventDisable;
}

@prod
@singleton
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  ConnectionBloc([
    ConnectionRepository connectionRepository,
    SettingsRepository settingsRepository,
  ])  : _connectionRepository =
            connectionRepository ?? getIt<ConnectionRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ConnectionRepository _connectionRepository;
  final SettingsRepository _settingsRepository;

  @override
  ConnectionState get initialState => ConnectionState.initial();

  Stream<ConnectionState> _ping() async* {
    yield ConnectionState.loading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold((Failure failure) async* {
      yield ConnectionState.failure(failure);
    }, (PiholeSettings settings) async* {
      final statusResult = await _connectionRepository.pingPihole(settings);

      yield* statusResult.fold((Failure failure) async* {
        yield ConnectionState.failure(failure);
      }, (status) async* {
        yield ConnectionState.active(status);
      });
    });
  }

  Stream<ConnectionState> _enable() async* {
    yield* state.maybeWhen(active: (status) async* {
      yield ConnectionState.failure(Failure('Teehee ${status.status}'));
    }, orElse: () async* {
      yield ConnectionState.failure(Failure('No active pihole'));
    });
  }

  Stream<ConnectionState> _disable() async* {}

  @override
  Stream<ConnectionState> mapEventToState(
    ConnectionEvent event,
  ) =>
      event.map(
        ping: (_) => _ping(),
        enable: (_) => _enable(),
        disable: (_) => _disable(),
      );
}

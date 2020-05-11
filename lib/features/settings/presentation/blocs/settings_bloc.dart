import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'settings_bloc.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = SettingsStateInitial;

  const factory SettingsState.loading() = SettingsStateLoading;

  const factory SettingsState.failure(Failure failure) = SettingsStateFailure;

  const factory SettingsState.success(
    List<PiholeSettings> all,
    PiholeSettings active,
  ) = SettingsStateSuccess;
}

@freezed
abstract class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.init() = SettingsEventInit;

  const factory SettingsEvent.reset() = SettingsEventReset;

  const factory SettingsEvent.create() = SettingsEventCreate;

  const factory SettingsEvent.activate(PiholeSettings settings) =
      SettingsEventActivate;

  const factory SettingsEvent.delete(PiholeSettings settings) =
      SettingsEventDelete;

  const factory SettingsEvent.update(
    PiholeSettings original,
    PiholeSettings update,
  ) = SettingsEventUpdate;
}

@prod
@singleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc([
    SettingsRepository settingsRepository,
  ]) : _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final SettingsRepository _settingsRepository;

  @override
  SettingsState get initialState => SettingsStateInitial();

  Stream<SettingsState> _init() async* {
    yield SettingsStateLoading();

    final Either<Failure, List<PiholeSettings>> allResult =
        await _settingsRepository.fetchAllPiholeSettings();
    yield* allResult.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (all) async* {
        final Either<Failure, PiholeSettings> activeResult =
            await _settingsRepository.fetchActivePiholeSettings();
        yield* activeResult.fold(
          (failure) async* {
            yield SettingsStateFailure(failure);
          },
          (active) async* {
            yield SettingsStateSuccess(all, active);
          },
        );
      },
    );
  }

  Stream<SettingsState> _reset() async* {
    yield SettingsState.loading();

    final resetResult = await _settingsRepository.deleteAllSettings();
    yield* resetResult.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (success) async* {
        yield* _init();
      },
    );
  }

  Stream<SettingsState> _create() async* {
    yield SettingsState.loading();

    final result = await _settingsRepository.createPiholeSettings();
    yield* result.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (success) async* {
        yield* _init();
      },
    );
  }

  Stream<SettingsState> _activate(PiholeSettings settings) async* {
    yield SettingsState.loading();

    final result = await _settingsRepository.activatePiholeSettings(settings);
    yield* result.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (success) async* {
        yield* _init();
      },
    );
  }

  Stream<SettingsState> _delete(PiholeSettings settings) async* {
    yield SettingsState.loading();

    await Future.delayed(Duration(seconds: 1));

    final result = await _settingsRepository.deletePiholeSettings(settings);
    yield* result.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (success) async* {
        yield* _init();
      },
    );
  }

  Stream<SettingsState> _update(
      PiholeSettings original, PiholeSettings update) async* {
    yield SettingsState.loading();

    final result =
        await _settingsRepository.updatePiholeSettings(original, update);
    yield* result.fold(
      (failure) async* {
        yield SettingsStateFailure(failure);
      },
      (success) async* {
        yield* _init();
      },
    );
  }

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) => event.when(
        init: () => _init(),
        reset: () => _reset(),
        create: () => _create(),
        activate: (settings) => _activate(settings),
        delete: (settings) => _delete(settings),
        update: (original, update) => _update(original, update),
      );
}

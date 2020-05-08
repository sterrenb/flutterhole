import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pihole_settings_bloc.freezed.dart';

@freezed
abstract class PiholeSettingsState with _$PiholeSettingsState {
  const factory PiholeSettingsState.initial() = PiholeSettingsStateInitial;

  const factory PiholeSettingsState.editing(
    PiholeSettings initialValue,
    PiholeSettings currentValue,
  ) = PiholeSettingsStateEditing;

  const factory PiholeSettingsState.failure(Failure failure) =
      PiholeSettingsStateFailure;
}

@freezed
abstract class PiholeSettingsEvent with _$PiholeSettingsEvent {
  const factory PiholeSettingsEvent.init(PiholeSettings initialValue) =
      PiholeSettingsEventInit;
}

class PiholeSettingsBloc
    extends Bloc<PiholeSettingsEvent, PiholeSettingsState> {
  PiholeSettingsBloc([
    ApiRepository apiRepository,
    SettingsRepository settingsRepository,
  ])  : _apiRepository = apiRepository ?? getIt<ApiRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  @override
  PiholeSettingsState get initialState => PiholeSettingsStateInitial();

  Stream<PiholeSettingsState> _init(PiholeSettings initialValue) async* {
    yield PiholeSettingsState.editing(initialValue, initialValue);
  }

  Stream<PiholeSettingsState> _update(PiholeSettings update) async* {
    yield* state.maybeWhen(
      editing: (initialValue, currentValue) async* {
        yield PiholeSettingsState.editing(initialValue, update);
      },
      orElse: () async* {
        yield PiholeSettingsState.failure(
            Failure('state is not $PiholeSettingsStateEditing'));
      },
    );
  }

  @override
  Stream<PiholeSettingsState> mapEventToState(
      PiholeSettingsEvent event) async* {
    if (event is PiholeSettingsEventInit) yield* _init(event.initialValue);
  }
}

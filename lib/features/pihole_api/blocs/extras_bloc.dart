import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_extras.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'extras_bloc.freezed.dart';

@freezed
abstract class ExtrasState with _$ExtrasState {
  const factory ExtrasState.initial() = ExtrasStateInitial;

  const factory ExtrasState.loading() = ExtrasStateLoading;

  const factory ExtrasState.success(PiExtras extras) = ExtrasStateSuccess;

  const factory ExtrasState.failure(Failure failure) = ExtrasStateFailure;
}

@freezed
abstract class ExtrasEvent with _$ExtrasEvent {
  const factory ExtrasEvent.start() = _Start;

  const factory ExtrasEvent.stop() = _Stop;

  const factory ExtrasEvent.fetch() = _Fetch;
}

@singleton
class ExtrasBloc extends Bloc<ExtrasEvent, ExtrasState> {
  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  Timer _timer;

  ExtrasBloc(
    this._apiRepository,
    this._settingsRepository,
  ) : super(ExtrasState.initial());

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }

  @override
  Stream<ExtrasState> mapEventToState(ExtrasEvent event) async* {
    yield* event.when(
      start: () async* {
        add(ExtrasEvent.fetch());

        _timer?.cancel();
        _timer = Timer.periodic(Duration(seconds: 5), (_) {
          add(ExtrasEvent.fetch());
        });
      },
      stop: () async* {
        _timer?.cancel();
      },
      fetch: () async* {
        yield ExtrasState.loading();

        final Either<Failure, PiholeSettings> active =
            await _settingsRepository.fetchActivePiholeSettings();

        yield* active.fold(
          (Failure failure) async* {
            yield ExtrasState.failure(failure);
          },
          (PiholeSettings settings) async* {
            final result = await _apiRepository.fetchExtras(settings);

            yield* result.fold((Failure failure) async* {
              yield ExtrasState.failure(failure);
            }, (extras) async* {
              yield ExtrasState.success(extras);
            });
          },
        );
      },
    );
  }
}

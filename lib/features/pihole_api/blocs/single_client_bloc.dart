import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_client.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'single_client_bloc.freezed.dart';

@freezed
abstract class SingleClientState with _$SingleClientState {
  const factory SingleClientState.initial() = SingleClientStateInitial;

  const factory SingleClientState.loading() = SingleClientStateLoading;

  const factory SingleClientState.failure(Failure failure) =
      SingleClientStateFailure;

  const factory SingleClientState.success(
    PiClient client,
    List<QueryData> queries,
  ) = SingleClientStateSuccess;
}

@freezed
abstract class SingleClientEvent with _$SingleClientEvent {
  const factory SingleClientEvent.fetchQueries(PiClient client) =
      SingleClientEventFetchQueries;
}

class SingleClientBloc extends Bloc<SingleClientEvent, SingleClientState> {
  SingleClientBloc([
    ApiRepository apiRepository,
    SettingsRepository settingsRepository,
  ])  : _apiRepository = apiRepository ?? getIt<ApiRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  @override
  SingleClientState get initialState => SingleClientState.initial();

  Stream<SingleClientState> _fetchQueries(PiClient client) async* {
    yield SingleClientStateLoading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold(
      (Failure failure) async* {
        yield SingleClientState.failure(failure);
      },
      (PiholeSettings settings) async* {
        final Either<Failure, List<QueryData>> result =
            await _apiRepository.fetchQueriesForClient(settings, client);

        yield* result.fold((Failure failure) async* {
          yield SingleClientState.failure(failure);
        }, (queries) async* {
          yield SingleClientState.success(client, queries);
        });
      },
    );
  }

  @override
  Stream<SingleClientState> mapEventToState(SingleClientEvent event) async* {
    if (event is SingleClientEventFetchQueries)
      yield* _fetchQueries(event.client);
  }
}

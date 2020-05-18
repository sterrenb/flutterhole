import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/models/query_data.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'query_log_bloc.freezed.dart';

@freezed
abstract class QueryLogState with _$QueryLogState {
  const factory QueryLogState.initial() = QueryLogStateInitial;

  const factory QueryLogState.loading() = QueryLogStateLoading;

  const factory QueryLogState.failure(Failure failure) = QueryLogStateFailure;

  const factory QueryLogState.success(List<QueryData> queries) =
      QueryLogStateSuccess;
}

@freezed
abstract class QueryLogEvent with _$QueryLogEvent {
  const factory QueryLogEvent.fetchAll() = QueryLogEventFetchAll;

  const factory QueryLogEvent.fetchSome(int maxResults) =
      QueryLogEventFetchSome;
}

class QueryLogBloc extends Bloc<QueryLogEvent, QueryLogState> {
  QueryLogBloc([
    ApiRepository apiRepository,
    SettingsRepository settingsRepository,
  ])  : _apiRepository = apiRepository ?? getIt<ApiRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  @override
  QueryLogState get initialState => QueryLogState.initial();

  Stream<QueryLogState> _fetch([int maxResults]) async* {
    yield QueryLogStateLoading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold(
      (Failure failure) async* {
        yield QueryLogState.failure(failure);
      },
      (PiholeSettings settings) async* {
        final Either<Failure, List<QueryData>> result =
            await _apiRepository.fetchManyQueryData(settings, maxResults);

        yield* result.fold((Failure failure) async* {
          yield QueryLogState.failure(failure);
        }, (queries) async* {
          yield QueryLogState.success(queries);
        });
      },
    );
  }

  @override
  Stream<QueryLogState> mapEventToState(QueryLogEvent event) => event.when(
        fetchAll: () => _fetch(),
        fetchSome: (maxResults) => _fetch(maxResults),
      );
}

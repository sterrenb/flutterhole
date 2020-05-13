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

part 'single_domain_bloc.freezed.dart';

@freezed
abstract class SingleDomainState with _$SingleDomainState {
  const factory SingleDomainState.initial() = SingleDomainStateInitial;

  const factory SingleDomainState.loading() = SingleDomainStateLoading;

  const factory SingleDomainState.failure(Failure failure) =
      SingleDomainStateFailure;

  const factory SingleDomainState.success(
    String domain,
    List<QueryData> queries,
  ) = SingleDomainStateSuccess;
}

@freezed
abstract class SingleDomainEvent with _$SingleDomainEvent {
  const factory SingleDomainEvent.fetchQueries(String domain) =
      SingleDomainEventFetchQueries;
}

class SingleDomainBloc extends Bloc<SingleDomainEvent, SingleDomainState> {
  SingleDomainBloc([
    ApiRepository apiRepository,
    SettingsRepository settingsRepository,
  ])  : _apiRepository = apiRepository ?? getIt<ApiRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  @override
  SingleDomainState get initialState => SingleDomainState.initial();

  Stream<SingleDomainState> _fetchQueries(String domain) async* {
    yield SingleDomainStateLoading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold(
      (Failure failure) async* {
        yield SingleDomainState.failure(failure);
      },
      (PiholeSettings settings) async* {
        final Either<Failure, List<QueryData>> result =
            await _apiRepository.fetchQueriesForDomain(settings, domain);

        yield* result.fold((Failure failure) async* {
          yield SingleDomainState.failure(failure);
        }, (queries) async* {
          yield SingleDomainState.success(domain, queries);
        });
      },
    );
  }

  @override
  Stream<SingleDomainState> mapEventToState(SingleDomainEvent event) async* {
    if (event is SingleDomainEventFetchQueries)
      yield* _fetchQueries(event.domain);
  }
}

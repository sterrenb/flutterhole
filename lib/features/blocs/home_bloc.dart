import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/api/data/models/over_time_data.dart';
import 'package:flutterhole/features/api/data/models/summary.dart';
import 'package:flutterhole/features/api/data/models/top_sources.dart';
import 'package:flutterhole/features/api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_bloc.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState.initial() = HomeStateInitial;

  const factory HomeState.loading() = HomeStateLoading;

  const factory HomeState.failure(Failure failure) = HomeStateFailure;

  const factory HomeState.success(
    Either<Failure, SummaryModel> summary,
    Either<Failure, OverTimeData> overTimeData,
    Either<Failure, TopSourcesResult> topSources,
    Either<Failure, DnsQueryTypeResult> dnsQueryTypes,
  ) = HomeStateSuccess;
}

@freezed
abstract class HomeEvent with _$HomeEvent {
  const factory HomeEvent.fetch() = HomeEventFetch;
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc([
    ApiRepository apiRepository,
    SettingsRepository settingsRepository,
  ])  : _apiRepository = apiRepository ?? getIt<ApiRepository>(),
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>();

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  @override
  HomeState get initialState => HomeStateInitial();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomeEventFetch) yield* _fetch();
  }

  Stream<HomeState> _fetch() async* {
    yield HomeStateLoading();

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold(
      (Failure failure) async* {
        yield HomeStateFailure(failure);
      },
      (PiholeSettings settings) async* {
        final List<Future> futures = [
          _apiRepository.fetchSummary(settings),
          _apiRepository.fetchQueriesOverTime(settings),
          _apiRepository.fetchTopSources(settings),
          _apiRepository.fetchQueryTypes(settings),
        ];

        final results = await Future.wait(futures);

        final Either<Failure, SummaryModel> summary = results.elementAt(0);
        final Either<Failure, OverTimeData> overTimeData = results.elementAt(1);
        final Either<Failure, TopSourcesResult> topSources =
            results.elementAt(2);
        final Either<Failure, DnsQueryTypeResult> dnsQueryTypes =
            results.elementAt(3);

        if (summary.isLeft() &&
            overTimeData.isLeft() &&
            topSources.isLeft() &&
            dnsQueryTypes.isLeft()) {
          yield HomeStateFailure(Failure('all requests failed'));
        } else {
          yield HomeStateSuccess(
            summary,
            overTimeData,
            topSources,
            dnsQueryTypes,
          );
        }
      },
    );
  }
}

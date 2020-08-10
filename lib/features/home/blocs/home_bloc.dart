import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/models/dns_query_type.dart';
import 'package:flutterhole/features/pihole_api/data/models/forward_destinations.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data.dart';
import 'package:flutterhole/features/pihole_api/data/models/over_time_data_clients.dart';
import 'package:flutterhole/features/pihole_api/data/models/summary.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_items.dart';
import 'package:flutterhole/features/pihole_api/data/models/top_sources.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
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
    Either<Failure, OverTimeDataClients> overTimeDataClients,
    Either<Failure, TopSourcesResult> topSources,
    Either<Failure, TopItems> topItems,
    Either<Failure, ForwardDestinationsResult> forwardDestinations,
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
        _settingsRepository = settingsRepository ?? getIt<SettingsRepository>(),
        super(HomeStateInitial());

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

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
          _apiRepository.fetchClientsOverTime(settings),
          _apiRepository.fetchTopSources(settings),
          _apiRepository.fetchTopItems(settings),
          _apiRepository.fetchForwardDestinations(settings),
          _apiRepository.fetchQueryTypes(settings),
        ];

        final results = await Future.wait(futures);

        final Either<Failure, SummaryModel> summary = results.elementAt(0);
        final Either<Failure, OverTimeData> overTimeData = results.elementAt(1);
        final Either<Failure, OverTimeDataClients> overTimeDataClients =
        results.elementAt(2);
        final Either<Failure, TopSourcesResult> topSources =
        results.elementAt(3);
        final Either<Failure, TopItems> topItems = results.elementAt(4);
        final Either<Failure, ForwardDestinationsResult> forwardDestinations =
        results.elementAt(5);
        final Either<Failure, DnsQueryTypeResult> dnsQueryTypes =
        results.elementAt(6);

        if (summary.isLeft() &&
            overTimeData.isLeft() &&
            overTimeDataClients.isLeft() &&
            topSources.isLeft() &&
            topItems.isLeft() &&
            forwardDestinations.isLeft() &&
            dnsQueryTypes.isLeft()) {
          List<Failure> failures = [];
          summary.leftMap((l) => failures.add(l));
          overTimeData.leftMap((l) => failures.add(l));
          overTimeDataClients.leftMap((l) => failures.add(l));
          topSources.leftMap((l) => failures.add(l));
          topItems.leftMap((l) => failures.add(l));
          forwardDestinations.leftMap((l) => failures.add(l));
          dnsQueryTypes.leftMap((l) => failures.add(l));

          yield HomeStateFailure(Failure(
            'all requests failed',
            failures,
          ));
        } else {
          yield HomeStateSuccess(
            summary,
            overTimeData,
            overTimeDataClients,
            topSources,
            topItems,
            forwardDestinations,
            dnsQueryTypes,
          );
        }
      },
    );
  }

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is HomeEventFetch) yield* _fetch();
  }
}

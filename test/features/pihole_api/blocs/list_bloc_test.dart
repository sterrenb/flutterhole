import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:mockito/mockito.dart';

import '../../../test_dependency_injection.dart';

class MockApiRepository extends Mock implements ApiRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  setUpAllForTest();

  ApiRepository mockApiRepository;
  SettingsRepository mockSettingsRepository;
  ListBloc bloc;

  setUp(() {
    mockApiRepository = MockApiRepository();
    mockSettingsRepository = MockSettingsRepository();
    bloc = ListBloc(mockApiRepository, mockSettingsRepository);
  });

  tearDown(() {
    bloc.close();
  });

  blocTest(
    'Emits [] when nothing is added',
    build: () => bloc,
    expect: [],
  );

  group('fetchLists', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final Whitelist whitelist = Whitelist(data: []);
    final Blacklist blacklist = Blacklist(data: []);

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.loaded] when fetchLists succeeds',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.fetchWhitelist(any))
            .thenAnswer((_) async => right(whitelist));
        when(mockApiRepository.fetchBlacklist(any))
            .thenAnswer((_) async => right(blacklist));
        return bloc;
      },
      act: (ListBloc bloc) async => bloc.add(ListBlocEvent.fetchLists()),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: none(),
          failureOption: none(),
          whitelist: whitelist,
          blacklist: blacklist,
        ),
      ],
    );

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.failure] when fetchLists fails',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.fetchWhitelist(any))
            .thenAnswer((_) async => left(Failure()));
        when(mockApiRepository.fetchBlacklist(any))
            .thenAnswer((_) async => right(blacklist));
        return bloc;
      },
      act: (ListBloc bloc) async => bloc.add(ListBlocEvent.fetchLists()),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: none(),
          failureOption: some(Failure('fetchLists failed', [Failure()])),
        ),
      ],
    );
  });

  group('addToWhitelist', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final String domain = 'domain';
    final ListResponse response = ListResponse(success: true);

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.editSuccess] when addToWhitelist succeeds',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.addToWhitelist(any, domain, false))
            .thenAnswer((_) async => right(response));
        return bloc;
      },
      act: (ListBloc bloc) async =>
          bloc.add(ListBlocEvent.addToWhitelist(domain, false)),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: some(response),
          failureOption: none(),
        ),
      ],
    );
  });

  group('addToBlacklist', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final String domain = 'domain';
    final ListResponse response = ListResponse(success: true);

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.editSuccess] when addToBlacklist succeeds',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.addToBlacklist(any, domain, false))
            .thenAnswer((_) async => right(response));
        return bloc;
      },
      act: (ListBloc bloc) async =>
          bloc.add(ListBlocEvent.addToBlacklist(domain, false)),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: some(response),
          failureOption: none(),
        ),
      ],
    );
  });

  group('addToWhitelist', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final String domain = 'domain';
    final WhitelistItem item = WhitelistItem(domain: domain);
    final ListResponse response = ListResponse(success: true);

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.editSuccess] when removeFromWhitelist succeeds',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.removeFromWhitelist(any, domain, false))
            .thenAnswer((_) async => right(response));
        return bloc;
      },
      act: (ListBloc bloc) async =>
          bloc.add(ListBlocEvent.removeFromWhitelist(item)),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: some(response),
          failureOption: none(),
        ),
      ],
    );
  });

  group('removeFromBlacklist', () {
    final piholeSettings = PiholeSettings(baseUrl: 'http://example.com');
    final String domain = 'domain';
    final WhitelistItem item = WhitelistItem(domain: domain);
    final ListResponse response = ListResponse(success: true);

    blocTest(
      'Emits [ListBlocState.loading, ListBlocState.editSuccess] when removeFromBlacklist succeeds',
      build: () {
        when(mockSettingsRepository.fetchActivePiholeSettings())
            .thenAnswer((_) async => Right(piholeSettings));
        when(mockApiRepository.removeFromBlacklist(any, domain, false))
            .thenAnswer((_) async => right(response));
        return bloc;
      },
      act: (ListBloc bloc) async =>
          bloc.add(ListBlocEvent.removeFromBlacklist(item)),
      expect: [
        ListBlocState(
          loading: true,
          responseOption: none(),
          failureOption: none(),
        ),
        ListBlocState(
          loading: false,
          responseOption: some(response),
          failureOption: none(),
        ),
      ],
    );
  });
}

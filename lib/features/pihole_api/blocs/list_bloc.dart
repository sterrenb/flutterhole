import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/api_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'list_bloc.freezed.dart';

@freezed
abstract class ListBlocState with _$ListBlocState {
  const factory ListBlocState({
    Whitelist whitelist,
    Blacklist blacklist,
    @required Option<ListResponse> responseOption,
    @required bool loading,
    @required Option<Failure> failureOption,
  }) = _ListBlocState;
}

@freezed
abstract class ListBlocEvent with _$ListBlocEvent {
  const factory ListBlocEvent.fetchLists() = _FetchLists;

  const factory ListBlocEvent.addToWhitelist(String domain, bool isWildcard) =
      _AddToWhitelist;

  const factory ListBlocEvent.removeFromWhitelist(
      String domain, bool isWildcard) = _RemoveFromWhitelist;

  const factory ListBlocEvent.addToBlacklist(String domain, bool isWildcard) =
      _AddToBlacklist;

  const factory ListBlocEvent.removeFromBlacklist(
      String domain, bool isWildcard) = _RemoveFromBlacklist;
}

typedef Future<Either<Failure, ListResponse>> ListFunction(
    PiholeSettings settings, String domain, bool isWildcard);

typedef Stream<ListBlocState> AfterEditSuccess(ListResponse response);

@singleton
class ListBloc extends Bloc<ListBlocEvent, ListBlocState> {
  ListBloc(this._apiRepository, this._settingsRepository)
      : super(ListBlocState(
          responseOption: none(),
          loading: false,
          failureOption: none(),
        ));

  final ApiRepository _apiRepository;
  final SettingsRepository _settingsRepository;

  Stream<ListBlocState> _fetchLists() async* {
    yield state.copyWith(
      loading: true,
      responseOption: none(),
      failureOption: none(),
    );

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold((Failure failure) async* {
      yield state.copyWith(
        loading: false,
        responseOption: none(),
        failureOption: some(failure),
      );
    }, (PiholeSettings settings) async* {
      final List<Future> futures = [
        _apiRepository.fetchWhitelist(settings),
        _apiRepository.fetchBlacklist(settings),
      ];
      final List results = await Future.wait(futures);

      final Either<Failure, Whitelist> whitelistResult = results.elementAt(0);
      final Either<Failure, Blacklist> blacklistResult = results.elementAt(1);

      List<Failure> failures = [];
      Whitelist whitelist;
      Blacklist blacklist;

      whitelistResult.fold(
          (Failure f) => failures.add(f), (Whitelist r) => whitelist = r);
      blacklistResult.fold(
          (Failure f) => failures.add(f), (Blacklist r) => blacklist = r);

      if (failures.isEmpty) {
        yield state.copyWith(
          loading: false,
          responseOption: none(),
          failureOption: none(),
          whitelist: Whitelist(
              data: List<WhitelistItem>.from(whitelist.data)
                ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded))),
          blacklist: blacklist,
        );
      } else {
        yield state.copyWith(
          loading: false,
          responseOption: none(),
          failureOption: some(Failure('fetchLists failed', failures)),
        );
      }
    });
  }

  Stream<ListBlocState> _doEdit(
    String domain,
    bool isWildcard,
    ListFunction f,
    AfterEditSuccess afterEditSuccess,
  ) async* {
    yield state.copyWith(
      loading: false,
      responseOption: none(),
      failureOption: none(),
    );

    final Either<Failure, PiholeSettings> active =
        await _settingsRepository.fetchActivePiholeSettings();

    yield* active.fold((Failure failure) async* {
      yield state.copyWith(
        loading: false,
        responseOption: none(),
        failureOption: some(failure),
      );
    }, (PiholeSettings settings) async* {
      final Either<Failure, ListResponse> result =
          await f(settings, domain, isWildcard);

      yield* result.fold((Failure f) async* {
        yield state.copyWith(
          loading: false,
          responseOption: none(),
          failureOption: some(f),
        );
      }, (ListResponse r) async* {
        yield state.copyWith(
          loading: false,
          responseOption: some(r),
          failureOption: none(),
        );
        yield* afterEditSuccess(r);
      });
    });
  }

  @override
  Stream<ListBlocState> mapEventToState(ListBlocEvent event) async* {
    yield* event.when(
      fetchLists: _fetchLists,
      addToWhitelist: (String domain, bool isWildcard) => _doEdit(
        domain,
        isWildcard,
        _apiRepository.addToWhitelist,
        (response) async* {},
      ),
      removeFromWhitelist: (String domain, bool isWildcard) => _doEdit(
        domain,
        isWildcard,
        _apiRepository.removeFromWhitelist,
        (response) async* {
          if (response.success) {
//            yield state.copyWith(
//              whitelist:
//            );
          }
        },
      ),
      addToBlacklist: (String domain, bool isWildcard) => _doEdit(
        domain,
        isWildcard,
        _apiRepository.addToBlacklist,
        (response) async* {},
      ),
      removeFromBlacklist: (String domain, bool isWildcard) => _doEdit(
        domain,
        isWildcard,
        _apiRepository.removeFromBlacklist,
        (response) async* {},
      ),
    );
  }
}

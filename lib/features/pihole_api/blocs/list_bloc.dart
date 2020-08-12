import 'package:bloc/bloc.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist.dart';
import 'package:flutterhole/features/pihole_api/data/models/list_response.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_bloc.freezed.dart';

@freezed
abstract class ListBlocState with _$ListBlocState {
  const factory ListBlocState.initial() = _Initial;

  const factory ListBlocState.loading() = _Loading;

  const factory ListBlocState.failure(Failure failure) = _Failure;

  const factory ListBlocState.loaded(
    Whitelist whitelist,
    Blacklist blacklist,
  ) = _Loaded;

  const factory ListBlocState.addSuccess(ListResponse response) = _AddSuccess;

  const factory ListBlocState.removeSuccess(ListResponse response) =
      _RemoveSuccess;
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

class ListBlocBloc extends Bloc<ListBlocEvent, ListBlocState> {
  ListBlocBloc() : super(ListBlocState.initial());

  @override
  Stream<ListBlocState> mapEventToState(ListBlocEvent event) async* {
    // TODO: implement mapEventToState
    throw UnimplementedError();
  }
}

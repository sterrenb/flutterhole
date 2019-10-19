import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/versions.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class FetchForPihole extends BlocEvent {
  final Pihole pihole;
  final bool cancelOldRequests;

  FetchForPihole(this.pihole, {this.cancelOldRequests = false});

  @override
  List<Object> get props => [pihole, cancelOldRequests];
}

class VersionsBloc extends BaseBloc<Versions> {
  VersionsBloc(BaseRepository<Versions> repository) : super(repository);

  Stream<BlocState> _fetchForPihole(Pihole pihole,
      {bool cancelOldRequests = false}) async* {
    if (cancelOldRequests) repository.client.cancel();

    try {
      final data = await (repository as VersionsRepository).get(pihole);
      yield BlocStateSuccess<Versions>(data);
    } on PiholeException catch (e) {
      yield BlocStateError<Versions>(e);
    }
  }

  @override
  Stream<BlocState> mapEventToState(
    BlocEvent event,
  ) async* {
    yield BlocStateLoading<Versions>();
    if (event is Fetch) yield* fetch();
    if (event is FetchForPihole) yield* _fetchForPihole(event.pihole);
  }
}

class VersionsRepository extends BaseRepository<Versions> {
  VersionsRepository(PiholeClient client) : super(client);

  @override
  Future<Versions> get([Pihole pihole]) async {
    return client.fetchVersions(pihole);
  }
}

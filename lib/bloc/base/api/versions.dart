import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/model/versions.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class FetchForPihole extends BlocEvent {
  final Pihole pihole;

  FetchForPihole(this.pihole) : super([pihole]);
}

class VersionsBloc extends BaseBloc<Versions> {
  VersionsBloc(BaseRepository<Versions> repository) : super(repository);

  Stream<BlocState> _fetchForPihole(Pihole pihole) async* {
    yield BlocStateLoading<Versions>();
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

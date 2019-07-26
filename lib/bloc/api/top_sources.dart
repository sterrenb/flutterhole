import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/top_sources.dart';
import 'package:flutterhole/service/pihole_client.dart';

class TopSourcesBloc extends BaseBloc<TopSources> {
  TopSourcesBloc(BaseRepository<TopSources> repository) : super(repository);
}

class TopSourcesRepository extends BaseRepository<TopSources> {
  TopSourcesRepository(PiholeClient client) : super(client);

  @override
  Future<TopSources> get() async {
    return client.fetchTopSources();
  }
}

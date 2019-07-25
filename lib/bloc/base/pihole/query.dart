import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/service/pihole_client.dart';

class QueryBloc extends BaseBloc<List<Query>> {
  QueryBloc(BaseRepository<List<Query>> repository) : super(repository);
}

class QueryRepository extends BaseRepository<List<Query>> {
  QueryRepository(PiholeClient client) : super(client);

  @override
  Future<List<Query>> get() async {
    final List<Query> queries = await client.fetchQueries();
    return queries..sort((a, b) => b.time.compareTo(a.time));
  }

  Future<List<Query>> getForClient(String client) async {
    final List<Query> queries = await this.client.fetchQueriesForClient(client);
    return queries..sort((a, b) => b.time.compareTo(a.time));
  }
}

class FetchForClient extends BlocEvent {
  final String client;

  FetchForClient(this.client) : super([client]);
}

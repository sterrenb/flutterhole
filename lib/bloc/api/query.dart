import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_client.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class FetchForClient extends BlocEvent {
  final String client;

  FetchForClient(this.client) : super([client]);
}

class FetchForQueryType extends BlocEvent {
  final QueryType type;

  FetchForQueryType(this.type) : super([type]);
}

class QueryBloc extends BaseBloc<List<Query>> {
  QueryBloc(QueryRepository repository) : super(repository);

  @override
  Stream<BlocState> mapEventToState(BlocEvent event,) async* {
    yield BlocStateLoading<List<Query>>();
    if (event is Fetch) yield* fetch();
    if (event is FetchForClient) yield* _fetchForClient(event.client);
    if (event is FetchForQueryType) yield* _fetchForQueryType(event.type);
  }

  Stream<BlocState> _fetchForClient(String client) async* {
    try {
      final data = await (repository as QueryRepository).getForClient(client);
      yield BlocStateSuccess<List<Query>>(data);
    } on PiholeException catch (e) {
      yield BlocStateError<List<Query>>(e);
    }
  }

  Stream<BlocState> _fetchForQueryType(QueryType type) async* {
    try {
      print('bloc: getting queries for query type');
      final data = await (repository as QueryRepository).getForQueryType(type);
      yield BlocStateSuccess<List<Query>>(data);
    } on PiholeException catch (e) {
      yield BlocStateError<List<Query>>(e);
    }
  }
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

  Future<List<Query>> getForQueryType(QueryType type) async {
    print('get for type');
    final List<Query> queries =
    await this.client.fetchQueriesForQueryType(type);
    return queries..sort((a, b) => b.time.compareTo(a.time));
  }
}

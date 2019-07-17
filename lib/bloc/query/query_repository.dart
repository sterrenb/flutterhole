import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/service/pihole_client.dart';

class QueryRepository extends ApiRepository {
  final PiholeClient client;
  List<Query> _cache = [];

  List<Query> get cache => _cache;

  QueryRepository(this.client);

  Future<List<Query>> getQueries() async {
    final List<Query> queries = await client.fetchQueries();
    _cache = queries..sort((a, b) => b.time.compareTo(a.time));
    return queries;
  }
}

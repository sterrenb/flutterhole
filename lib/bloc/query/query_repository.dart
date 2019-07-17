import 'package:flutterhole_again/bloc/api_repository.dart';
import 'package:flutterhole_again/model/query.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

class QueryRepository extends ApiRepository {
  final PiholeClient client;
  List<Query> _cache = [];

  List<Query> get cache => _cache;

  QueryRepository(this.client);

  Future<List<Query>> getQueries() async {
    final List<Query> queries = await client.getQueries();
    _cache = queries..sort((a, b) => b.time.compareTo(a.time));
    return queries;
  }
}

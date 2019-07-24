import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/query.dart';
import 'package:flutterhole/service/pihole_client.dart';

class QueryTypesRepository extends ApiRepository {
  final PiholeClient client;

  QueryTypesRepository(this.client);

  Future<QueryTypes> getQueryTypes() async {
    return client.fetchQueryTypes();
  }
}

import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/query.dart';
import 'package:flutterhole/service/pihole_client.dart';

class QueryTypesBloc extends BaseBloc<QueryTypes> {
  QueryTypesBloc(BaseRepository<QueryTypes> repository) : super(repository);
}

class QueryTypesRepository extends BaseRepository<QueryTypes> {
  QueryTypesRepository(PiholeClient client) : super(client);

  @override
  Future<QueryTypes> get() async {
    return client.fetchQueryTypes();
  }
}

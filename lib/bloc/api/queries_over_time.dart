import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/queries_over_time.dart';
import 'package:flutterhole/service/pihole_client.dart';

class QueriesOverTimeBloc extends BaseBloc<QueriesOverTime> {
  QueriesOverTimeBloc(BaseRepository<QueriesOverTime> repository)
      : super(repository);
}

class QueriesOverTimeRepository extends BaseRepository<QueriesOverTime> {
  QueriesOverTimeRepository(PiholeClient client) : super(client);

  @override
  Future<QueriesOverTime> get() async {
    print('bloc: fetching');
    final x = await client.fetchQueriesOverTime();
    print(x.domainsOverTime.values.first);
    return x;
  }
}

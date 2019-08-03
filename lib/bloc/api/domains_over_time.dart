import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/domains_over_time.dart';
import 'package:flutterhole/service/pihole_client.dart';

class DomainsOverTimeBloc extends BaseBloc<DomainsOverTime> {
  DomainsOverTimeBloc(BaseRepository<DomainsOverTime> repository)
      : super(repository);
}

class DomainsOverTimeRepository extends BaseRepository<DomainsOverTime> {
  DomainsOverTimeRepository(PiholeClient client) : super(client);

  @override
  Future<DomainsOverTime> get() async {
    return client.fetchDomainsOverTime();
  }
}

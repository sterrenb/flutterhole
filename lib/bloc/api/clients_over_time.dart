import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/clients_over_time.dart';
import 'package:flutterhole/service/pihole_client.dart';

class ClientsOverTimeBloc extends BaseBloc<ClientsOverTime> {
  ClientsOverTimeBloc(BaseRepository<ClientsOverTime> repository)
      : super(repository);
}

class ClientsOverTimeRepository extends BaseRepository<ClientsOverTime> {
  ClientsOverTimeRepository(PiholeClient client) : super(client);

  @override
  Future<ClientsOverTime> get() async {
    return client.fetchClientsOverTime();
  }
}

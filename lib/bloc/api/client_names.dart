import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/client_names.dart';
import 'package:flutterhole/service/pihole_client.dart';

class ClientNamesBloc extends BaseBloc<ClientNames> {
  ClientNamesBloc(BaseRepository<ClientNames> repository) : super(repository);
}

class ClientNamesRepository extends BaseRepository<ClientNames> {
  ClientNamesRepository(PiholeClient client) : super(client);

  @override
  Future<ClientNames> get() async {
    return client.fetchClientNames();
  }
}

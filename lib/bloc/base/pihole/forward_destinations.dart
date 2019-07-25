import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/forward_destinations.dart';
import 'package:flutterhole/service/pihole_client.dart';

class ForwardDestinationsBloc extends BaseBloc<ForwardDestinations> {
  ForwardDestinationsBloc(BaseRepository<ForwardDestinations> repository)
      : super(repository);
}

class ForwardDestinationsRepository
    extends BaseRepository<ForwardDestinations> {
  ForwardDestinationsRepository(PiholeClient client) : super(client);

  @override
  Future<ForwardDestinations> get() async {
    return client.fetchForwardDestinations();
  }
}

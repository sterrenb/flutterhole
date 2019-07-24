import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/forward_destinations.dart';
import 'package:flutterhole/service/pihole_client.dart';

class ForwardDestinationsRepository extends ApiRepository {
  final PiholeClient client;

  ForwardDestinationsRepository(this.client);

  Future<ForwardDestinations> getForwardDestinations() {
    return client.fetchForwardDestinations();
  }
}

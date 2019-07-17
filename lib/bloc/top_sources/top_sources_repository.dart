import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/top_sources.dart';
import 'package:flutterhole/service/pihole_client.dart';

class TopSourcesRepository extends ApiRepository {
  final PiholeClient client;

  TopSourcesRepository(this.client);

  Future<TopSources> getTopSources() {
    return client.fetchTopSources();
  }
}

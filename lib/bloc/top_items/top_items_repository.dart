import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/top_items.dart';
import 'package:flutterhole/service/pihole_client.dart';

class TopItemsRepository extends ApiRepository {
  final PiholeClient client;

  TopItemsRepository(this.client);

  Future<TopItems> getTopItems() {
    return client.fetchTopItems();
  }
}

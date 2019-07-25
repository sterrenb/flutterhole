import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/bloc/base/repository.dart';
import 'package:flutterhole/model/api/top_items.dart';
import 'package:flutterhole/service/pihole_client.dart';

class TopItemsBloc extends BaseBloc<TopItems> {
  TopItemsBloc(BaseRepository<TopItems> repository) : super(repository);
}

class TopItemsRepository extends BaseRepository<TopItems> {
  TopItemsRepository(PiholeClient client) : super(client);

  @override
  Future<TopItems> get() async {
    return client.fetchTopItems();
  }
}

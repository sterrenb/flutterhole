import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/service/pihole_client.dart';

abstract class BaseRepository<T> extends ApiRepository {
  final PiholeClient client;

  BaseRepository(this.client);

  Future<T> get();
}

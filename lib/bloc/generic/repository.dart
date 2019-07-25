import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/service/pihole_client.dart';

abstract class GenericRepository<T> extends ApiRepository {
  final PiholeClient client;

  GenericRepository(this.client);

  Future<T> get();
}

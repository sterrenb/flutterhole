import 'package:flutterhole/service/pihole_client.dart';
import 'package:meta/meta.dart';

/// Bloc repository with a [PiholeClient].
abstract class ApiRepository {
  final PiholeClient client;

  ApiRepository({@required this.client});
}

abstract class BaseRepository<T> extends ApiRepository {
  final PiholeClient client;

  BaseRepository(this.client);

  Future<T> get();
}

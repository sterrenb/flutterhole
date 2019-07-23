import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/model/versions.dart';
import 'package:flutterhole/service/pihole_client.dart';

class VersionsRepository extends ApiRepository {
  final PiholeClient client;

  VersionsRepository(this.client);

  Future<Versions> getVersions([Pihole pihole]) {
    return client.fetchVersions(pihole);
  }
}

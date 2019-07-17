import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/summary.dart';
import 'package:flutterhole/service/pihole_client.dart';


class SummaryRepository extends ApiRepository {
  final PiholeClient client;

  SummaryRepository(this.client);

  Future<Summary> getSummary() {
    return client.fetchSummary();
  }
}

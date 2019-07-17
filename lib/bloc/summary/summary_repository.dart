import 'package:flutterhole_again/bloc/api_repository.dart';
import 'package:flutterhole_again/model/summary.dart';
import 'package:flutterhole_again/service/pihole_client.dart';


class SummaryRepository extends ApiRepository {
  final PiholeClient client;

  SummaryRepository(this.client);

  Future<Summary> getSummary() {
    return client.fetchSummary();
  }
}

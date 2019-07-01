import 'package:flutterhole_again/service/pihole_client.dart';
import 'package:meta/meta.dart';

/// Bloc repository with a [PiholeClient].
abstract class ApiRepository {
  final PiholeClient client;

  ApiRepository({@required this.client});
}

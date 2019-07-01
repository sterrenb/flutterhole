import 'package:flutterhole_again/model/status.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

import 'api_repository.dart';

class StatusRepository extends ApiRepository {
  final PiholeClient client;
  final Stopwatch _stopwatch = Stopwatch();

  StatusRepository(this.client);

  Duration get elapsed => _stopwatch.elapsed;

  Future<Status> getStatus() async {
    final enabled = await client.fetchEnabled();
    return Status(enabled: enabled);
  }

  Future<Status> enable() async {
    await client.enable();
    _stopwatch.stop();
    _stopwatch.reset();
    return Status(enabled: true);
  }

  Future<Status> disable() async {
    await client.disable();
    return Status(enabled: false);
  }

  Future<Status> sleep(Duration duration) async {
    await client.disable(duration: duration);
    _stopwatch.reset();
    _stopwatch.start();
    return Status(enabled: false);
  }
}

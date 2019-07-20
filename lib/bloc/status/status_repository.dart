import 'dart:async';

import 'package:flutterhole/bloc/api_repository.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/service/pihole_client.dart';

class StatusRepository extends ApiRepository {
  final PiholeClient client;
  final Stopwatch _stopwatch = Stopwatch();

  Stopwatch get stopwatch => _stopwatch;

  Timer _timer;

  StatusRepository(this.client);

  Duration get elapsed => _stopwatch.elapsed;

  Future<Status> getStatus() async {
    final status = await client.fetchStatus();
    return status;
  }

  Future<Status> enable() async {
    final status = await client.enable();
    _stopwatch.stop();
    _stopwatch.reset();
    return status;
  }

  Future<Status> disable() async {
    return client.disable();
  }

  Future<Status> sleep(Duration duration, void callback()) async {
    final status = await client.disable(duration);
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer(duration, callback);
    return status;
  }

  void cancelSleep() {
    _timer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
  }
}

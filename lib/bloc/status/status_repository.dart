import 'dart:async';

import 'package:flutterhole_again/bloc/api_repository.dart';
import 'package:flutterhole_again/model/status.dart';
import 'package:flutterhole_again/service/pihole_client.dart';

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
    await client.enable();
    _stopwatch.stop();
    _stopwatch.reset();
    return Status(enabled: true);
  }

  Future<Status> disable() async {
    await client.disable();
    return Status(enabled: false);
  }

  Future<Status> sleep(Duration duration, void callback()) async {
    await client.disable(duration: duration);
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer(duration, callback);
    return Status(enabled: false);
  }

  void cancelSleep() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _stopwatch.stop();
    _stopwatch.reset();
  }
}

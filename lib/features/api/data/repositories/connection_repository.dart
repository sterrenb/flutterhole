import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/api/data/models/pi_status.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class ConnectionRepository {
  Future<Either<Failure, int>> fetchHostStatusCode(PiholeSettings settings);

  Future<Either<Failure, PiStatusEnum>> fetchPiholeStatus(PiholeSettings settings);

  Future<Either<Failure, bool>> fetchAuthenticatedStatus(
      PiholeSettings settings);
}

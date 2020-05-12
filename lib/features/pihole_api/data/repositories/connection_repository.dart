import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/models/toggle_status.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class ConnectionRepository {
  Future<Either<Failure, int>> fetchHostStatusCode(PiholeSettings settings);

  Future<Either<Failure, PiStatusEnum>> fetchPiholeStatus(
      PiholeSettings settings);

  Future<Either<Failure, PiVersions>> fetchVersions(PiholeSettings settings);

  Future<Either<Failure, bool>> fetchAuthenticatedStatus(
      PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> pingPihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> enablePihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> disablePihole(PiholeSettings settings);

  Future<Either<Failure, ToggleStatus>> sleepPihole(
      PiholeSettings settings, Duration duration);
}

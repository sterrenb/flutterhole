import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, PiholeSettings>> createPiholeSettings();

  Future<Either<Failure, bool>> updatePiholeSettings(
      PiholeSettings piholeSettings);

  Future<Either<Failure, bool>> deletePiholeSettings(
      PiholeSettings piholeSettings);

  Future<Either<Failure, bool>> activatePiholeSettings(
      PiholeSettings piholeSettings);

  Future<Either<Failure, List<PiholeSettings>>> fetchAllPiholeSettings(
      PiholeSettings piholeSettings);
  
  Future<Either<Failure, PiholeSettings>> fetchActivePiholeSettings();
}

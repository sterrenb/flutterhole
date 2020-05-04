import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@prod
@injectable
@RegisterAs(SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl([SettingsDataSource settingsDataSource])
      : _settingsDataSource = settingsDataSource ?? getIt<SettingsDataSource>();

  final SettingsDataSource _settingsDataSource;

  /// Wrapper for accessing simple [SettingsDataSource] methods.
  Future<Either<Failure, T>> _simpleSettings<T>(
    PiholeSettings settings,
    Function dataSourceMethod,
  ) async {
    try {
      final T result = await dataSourceMethod(settings);
      return Right(result);
    } on PiException catch (_) {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, bool>> activatePiholeSettings(
      PiholeSettings piholeSettings) async {
    return _simpleSettings<bool>(
        piholeSettings, _settingsDataSource.activatePiholeSettings);
  }

  @override
  Future<Either<Failure, PiholeSettings>> createPiholeSettings() async {
    try {
      final PiholeSettings result =
          await _settingsDataSource.createPiholeSettings();
      return Right(result);
    } on PiException catch (_) {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, bool>> deletePiholeSettings(
      PiholeSettings piholeSettings) async {
    return _simpleSettings<bool>(
        piholeSettings, _settingsDataSource.deletePiholeSettings);
  }

  @override
  Future<Either<Failure, List<PiholeSettings>>> fetchAllPiholeSettings(
      PiholeSettings piholeSettings) async {
    try {
      final List<PiholeSettings> result =
          await _settingsDataSource.fetchAllPiholeSettings();
      return Right(result);
    } on PiException catch (_) {
      return Left(Failure());
    }
  }

  @override
  Future<Either<Failure, bool>> updatePiholeSettings(
      PiholeSettings piholeSettings) async {
    return _simpleSettings<bool>(
        piholeSettings, _settingsDataSource.updatePiholeSettings);
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutterhole/core/models/exceptions.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:flutterhole/features/settings/data/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@prod
@singleton
@RegisterAs(SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl([SettingsDataSource settingsDataSource])
      : _settingsDataSource = settingsDataSource ?? getIt<SettingsDataSource>();

  final SettingsDataSource _settingsDataSource;

  /// Wrapper for accessing simple [SettingsDataSource] methods.
  Future<Either<Failure, T>> _simpleSettings<T>(
    PiholeSettings settings,
    Function dataSourceMethod,
    String description,
  ) async {
    try {
      final T result = await dataSourceMethod(settings);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('$description failed', e));
    }
  }

  @override
  Future<Either<Failure, bool>> activatePiholeSettings(
      PiholeSettings piholeSettings) async {
    return _simpleSettings<bool>(
      piholeSettings,
      _settingsDataSource.activatePiholeSettings,
      'activatePiholeSettings',
    );
  }

  @override
  Future<Either<Failure, PiholeSettings>> createPiholeSettings() async {
    try {
      final PiholeSettings result =
          await _settingsDataSource.createPiholeSettings();
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('createPiholeSettings failed', e));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePiholeSettings(
      PiholeSettings piholeSettings) async {
    return _simpleSettings<bool>(
      piholeSettings,
      _settingsDataSource.deletePiholeSettings,
      'deletePiholeSettings',
    );
  }

  @override
  Future<Either<Failure, bool>> deleteAllSettings() async {
    try {
      final bool result = await _settingsDataSource.deleteAllSettings();
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('deleteAllSettings failed', e));
    }
  }

  @override
  Future<Either<Failure, List<PiholeSettings>>> fetchAllPiholeSettings() async {
    try {
      final List<PiholeSettings> result =
          await _settingsDataSource.fetchAllPiholeSettings();

      if (result.isEmpty) {
        final settings = await _settingsDataSource.createPiholeSettings();
        await _settingsDataSource.activatePiholeSettings(settings);
        return Right([settings]);
      }

      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('fetchAllPiholeSettings failed', e));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePiholeSettings(
    PiholeSettings original,
    PiholeSettings update,
  ) async {
    try {
      final bool result =
      await _settingsDataSource.updatePiholeSettings(original, update);
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('updatePiholeSettings failed', e));
    }
  }

  @override
  Future<Either<Failure, PiholeSettings>> fetchActivePiholeSettings() async {
    try {
      final PiholeSettings result =
          await _settingsDataSource.fetchActivePiholeSettings();
      return Right(result);
    } on PiException catch (e) {
      return Left(Failure('fetchActivePiholeSettings failed', e));
    }
  }
}

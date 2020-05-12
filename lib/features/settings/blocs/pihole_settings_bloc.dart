import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_status.dart';
import 'package:flutterhole/features/pihole_api/data/models/pi_versions.dart';
import 'package:flutterhole/features/pihole_api/data/repositories/connection_repository.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pihole_settings_bloc.freezed.dart';

@freezed
abstract class PiholeSettingsState with _$PiholeSettingsState {
  const factory PiholeSettingsState.initial() = PiholeSettingsStateInitial;

  const factory PiholeSettingsState.loading() = PiholeSettingsStateLoading;

  const factory PiholeSettingsState.validated(
    PiholeSettings settings,
    Either<Failure, int> hostStatusCode,
    Either<Failure, PiStatusEnum> piholeStatus,
    Either<Failure, bool> authenticatedStatus,
      Either<Failure, PiVersions> versions,
  ) = PiholeSettingsStateValidated;

  const factory PiholeSettingsState.failure(Failure failure) =
      PiholeSettingsStateFailure;
}

@freezed
abstract class PiholeSettingsEvent with _$PiholeSettingsEvent {
  const factory PiholeSettingsEvent.validate(PiholeSettings settings) =
      PiholeSettingsEventValidate;
}

class PiholeSettingsBloc
    extends Bloc<PiholeSettingsEvent, PiholeSettingsState> {
  PiholeSettingsBloc([ConnectionRepository connectionRepository])
      : _connectionRepository =
            connectionRepository ?? getIt<ConnectionRepository>();

  final ConnectionRepository _connectionRepository;

  @override
  PiholeSettingsState get initialState => PiholeSettingsStateInitial();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  Stream<PiholeSettingsState> _validate(PiholeSettings settings) async* {
    yield PiholeSettingsState.loading();

    await Future.delayed(Duration(milliseconds: 500));

    final List<Future> futures = [
      _connectionRepository.fetchHostStatusCode(settings),
      _connectionRepository.fetchPiholeStatus(settings),
      _connectionRepository.fetchAuthenticatedStatus(settings),
      _connectionRepository.fetchVersions(settings),
    ];

    final results = await Future.wait(futures);

    final Either<Failure, int> hostStatusCode = results.elementAt(0);
    final Either<Failure, PiStatusEnum> piholeStatusResult =
        results.elementAt(1);
    final Either<Failure, bool> authenticatedResult = results.elementAt(2);
    final Either<Failure, PiVersions> versionsResult = results.elementAt(3);

    yield PiholeSettingsStateValidated(
      settings,
      hostStatusCode,
      piholeStatusResult,
      authenticatedResult,
      versionsResult,
    );
  }

  @override
  Stream<PiholeSettingsState> mapEventToState(
      PiholeSettingsEvent event) async* {
    if (event is PiholeSettingsEventValidate) yield* _validate(event.settings);
  }
}

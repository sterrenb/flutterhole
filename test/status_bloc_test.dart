
import 'package:flutterhole_again/bloc/status/status_bloc.dart';
import 'package:flutterhole_again/bloc/status/status_event.dart';
import 'package:flutterhole_again/bloc/status/status_state.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/model/status.dart';
import 'package:flutterhole_again/model/summary.dart';
import 'package:flutterhole_again/model/whitelist.dart';
import 'package:flutterhole_again/repository/status_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockStatusRepository extends Mock implements StatusRepository {}

main() {
  MockStatusRepository statusRepository;
  StatusBloc statusBloc;

  setUp(() {
    statusRepository = MockStatusRepository();
    statusBloc = StatusBloc(statusRepository);
  });

  test('has a correct initialState', () {
    expect(statusBloc.initialState, StatusStateEmpty());
  });

  group('GetStatus', () {
    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateSuccess] when status repository returns Status',
        () {
      final Status status = Status(enabled: true);

      when(statusRepository.getStatus())
          .thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateSuccess(status),
          ]));

      statusBloc.dispatch(GetStatus());
    });

    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateError] when status repository throws PiholeException',
        () {
      when(statusRepository.getStatus()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateError(),
          ]));

      statusBloc.dispatch(GetStatus());
    });
  });

  group('EnableStatus', () {
    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateSuccess] when status repository returns',
        () {
      final Status status = Status(enabled: true);

      when(statusRepository.enable()).thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateSuccess(status),
          ]));

      statusBloc.dispatch(EnableStatus());
    });

    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateError] when status repository throws PiholeException',
        () {
      when(statusRepository.enable()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateError(),
          ]));

      statusBloc.dispatch(EnableStatus());
    });
  });

  group('DisableStatus', () {
    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateSuccess] when status repository returns',
        () {
      final Status status = Status(enabled: false);

      when(statusRepository.disable()).thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateSuccess(status),
          ]));

      statusBloc.dispatch(DisableStatus());
    });

    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateError] when status repository throws PiholeException',
        () {
      when(statusRepository.disable()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateError(),
          ]));

      statusBloc.dispatch(DisableStatus());
    });
  });

  group('SleepStatus', () {
    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateSleeping] when status repository returns',
        () {
      final Status status = Status(enabled: false);
      final Duration duration = Duration(seconds: 5);
      when(statusRepository.sleep(duration))
          .thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateSleeping(duration, duration),
          ]));

      statusBloc.dispatch(SleepStatus(duration));
    });

    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateError] when status repository throws PiholeException',
        () {
      final Duration duration = Duration(seconds: 5);

      when(statusRepository.sleep(duration)).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateError(),
          ]));

      statusBloc.dispatch(SleepStatus(duration));
    });
  });
}

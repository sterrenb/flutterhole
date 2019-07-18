import 'package:flutterhole/bloc/status/bloc.dart';
import 'package:flutterhole/bloc/status/status_repository.dart';
import 'package:flutterhole/model/status.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockStatusRepository extends Mock implements StatusRepository {
  Stopwatch stopwatch;
}

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

      statusBloc.dispatch(FetchStatus());
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
            StatusStateError(e: PiholeException()),
          ]));

      statusBloc.dispatch(FetchStatus());
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
            StatusStateError(e: PiholeException()),
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
            StatusStateError(e: PiholeException()),
          ]));

      statusBloc.dispatch(DisableStatus());
    });
  });

  group('SleepStatus', () {
    test(
        'emits [StatusStateEmpty, StatusStateLoading, StatusStateError] when status repository throws PiholeException',
        () {
      final Duration duration = Duration(seconds: 5);

      when(statusRepository.sleep(duration, () {}))
          .thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            StatusStateEmpty(),
            StatusStateLoading(),
            StatusStateError(e: PiholeException()),
          ]));

      statusBloc.dispatch(SleepStatus(duration));
    });
  });
}

import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/status.dart';
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
    expect(statusBloc.initialState, BlocStateEmpty<Status>());
  });

  group('GetStatus', () {
    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateSuccess<Status>] when status repository returns Status',
        () {
      final Status status = Status(enabled: true);

      when(statusRepository.get()).thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateSuccess<Status>(status),
          ]));

      statusBloc.dispatch(Fetch());
    });

    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateError<Status>] when status repository throws PiholeException',
        () {
          when(statusRepository.get()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateError<Status>(PiholeException()),
          ]));

          statusBloc.dispatch(Fetch());
    });
  });

  group('EnableStatus', () {
    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateSuccess<Status>] when status repository returns',
        () {
      final Status status = Status(enabled: true);

      when(statusRepository.enable()).thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateSuccess<Status>(status),
          ]));

      statusBloc.dispatch(EnableStatus());
    });

    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateError<Status>] when status repository throws PiholeException',
        () {
      when(statusRepository.enable()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateError<Status>(PiholeException()),
          ]));

      statusBloc.dispatch(EnableStatus());
    });
  });

  group('DisableStatus', () {
    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateSuccess<Status>] when status repository returns',
        () {
      final Status status = Status(enabled: false);

      when(statusRepository.disable()).thenAnswer((_) => Future.value(status));

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateSuccess<Status>(status),
          ]));

      statusBloc.dispatch(DisableStatus());
    });

    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateError<Status>] when status repository throws PiholeException',
        () {
      when(statusRepository.disable()).thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateError<Status>(PiholeException()),
          ]));

      statusBloc.dispatch(DisableStatus());
    });
  });

  group('SleepStatus', () {
    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateError<Status>] when status repository throws PiholeException',
        () {
      final Duration duration = Duration(seconds: 5);

      when(statusRepository.sleep(duration, () {}))
          .thenThrow(PiholeException());

      expectLater(
          statusBloc.state,
          emitsInOrder([
            BlocStateEmpty<Status>(),
            BlocStateLoading<Status>(),
            BlocStateError<Status>(PiholeException()),
          ]));

      statusBloc.dispatch(SleepStatus(duration));
    });
  });
}

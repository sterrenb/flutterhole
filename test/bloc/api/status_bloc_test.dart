import 'package:flutterhole/bloc/api/status.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/status.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mock.dart';

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
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, StatusStateSleeping] on successful sleep',
            () async {
          final Duration duration = Duration(milliseconds: 1);
          statusRepository.stopwatch = Stopwatch();

          when(statusRepository.sleep(duration, any))
              .thenAnswer((_) => Future.value(mockStatusDisabled));

          statusBloc.dispatch(SleepStatus(duration));

          expectLater(
              statusBloc.state,
              emitsInOrder([
                BlocStateEmpty<Status>(),
                BlocStateLoading<Status>(),
                StatusStateSleeping(duration, statusRepository.stopwatch),
              ]));
        });

    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateError<Status>] when status repository throws PiholeException',
            () {
          final Duration duration = Duration(seconds: 1);

          when(statusRepository.sleep(duration, any)).thenThrow(
              PiholeException());

          expectLater(
              statusBloc.state,
              emitsInOrder([
                BlocStateEmpty<Status>(),
                BlocStateLoading<Status>(),
                BlocStateError<Status>(PiholeException()),
              ]));

          statusBloc.dispatch(SleepStatus(duration));
        });

    test(
        'emits [BlocStateEmpty<Status>, BlocStateLoading<Status>, BlocStateSuccess<Status>] on successful wake',
            () {
          expectLater(
              statusBloc.state,
              emitsInOrder([
                BlocStateEmpty<Status>(),
                BlocStateLoading<Status>(),
                BlocStateSuccess<Status>(mockStatusEnabled),
              ]));

          statusBloc.dispatch(WakeStatus());
        });
  });

  group('repository', () {
    MockPiholeClient client;
    StatusRepository statusRepository;

    setUp(() {
      client = MockPiholeClient();
      statusRepository = StatusRepository(client);
    });

    test('initial stopwatch is stopped', () {
      expect(statusRepository.stopwatch.isRunning, isFalse);
    });

    test('getStatus', () {
      when(client.fetchStatus())
          .thenAnswer((_) => Future.value(mockStatusEnabled));

      expect(statusRepository.get(), completion(mockStatusEnabled));
    });

    test('enable', () {
      when(client.enable()).thenAnswer((_) => Future.value(mockStatusEnabled));

      expect(statusRepository.enable(), completion(mockStatusEnabled));
    });

    test('disable', () {
      when(client.disable())
          .thenAnswer((_) => Future.value(mockStatusDisabled));

      expect(statusRepository.disable(), completion(mockStatusDisabled));
    });

    test('sleep', () async {
      final duration = Duration(seconds: 5);

      when(client.disable(duration))
          .thenAnswer((_) => Future.value(mockStatusDisabled));

      final status = await statusRepository.sleep(duration, () {});

      expect(status, mockStatusDisabled);
      expect(statusRepository.stopwatch.isRunning, isTrue);
      expect(statusRepository.elapsed.inMicroseconds, greaterThan(0));

      expect(statusRepository.sleep(duration, () {}),
          completion(mockStatusDisabled));
    });

    test('cancelSleep', () {
      statusRepository.cancelSleep();
      expect(statusRepository.stopwatch.isRunning, isFalse);
      expect(statusRepository.elapsed.inMicroseconds, equals(0));
    });

    test('cancelSleep while sleeping', () {
      statusRepository.sleep(Duration(seconds: 5), () {});
      statusRepository.cancelSleep();
      expect(statusRepository.stopwatch.isRunning, isFalse);
      expect(statusRepository.elapsed.inMicroseconds, equals(0));
    });
  });
}

import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockRepository extends Mock implements PiholeRepository {}

main() {
  group('bloc', () {
    MockRepository repository;
    PiholeBloc piholeBloc;

    Pihole pihole;
    List<Pihole> piholes;

    setUp(() {
      repository = MockRepository();
      piholeBloc = PiholeBloc(repository);
      piholes = mockPiholes;
    });

    test('has a correct initialState', () {
      expect(piholeBloc.initialState, PiholeStateEmpty());
    });

    group('fetchPiholes', () {
      test(
          'emits [PiholeStateEmpty, PiholeStateLoading, PiholeStateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes()).thenAnswer((_) => piholes);
            when(repository.active()).thenAnswer((_) => piholes.first);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(all: piholes, active: piholes.first),
                ]));

            piholeBloc.dispatch(FetchPiholes());
          });

      test(
          'emits [PiholeStateEmpty, PiholeStateLoading, PiholeStateError] when pihole repository throws PiholeException',
              () {
            when(repository.getPiholes()).thenThrow(PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(FetchPiholes());
          });
    });

    group('resetPiholes', () {
      test(
          'emits [PiholeStateEmpty, PiholeStateLoading, PiholeStateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes()).thenAnswer((_) => piholes);
            when(repository.active()).thenAnswer((_) => piholes.first);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(all: piholes, active: piholes.first),
                ]));

            piholeBloc.dispatch(ResetPiholes());
          });

      test(
          'emits [PiholeStateEmpty, PiholeStateLoading, PiholeStateError] when pihole repository throws PiholeException',
              () {
            when(repository.getPiholes()).thenThrow(PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(ResetPiholes());
          });
    });

    group('addPihole', () {
      setUp(() {
        pihole = Pihole(title: 'Add', port: 0);
      });

      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes()).thenAnswer((_) =>
            piholes
              ..add(pihole));
            when(repository.add(pihole)).thenAnswer((_) => Future.value(true));
            when(repository.active()).thenAnswer((_) => piholes.first);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(
                      all: piholes..add(pihole), active: piholes.first),
                ]));

            piholeBloc.dispatch(AddPihole(pihole));
          });

      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateError] when pihole repository throws PiholeException',
              () {
            when(repository.add(pihole)).thenThrow(PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(AddPihole(pihole));
          });
    });

    group('removePihole', () {
      setUp(() {
        pihole = Pihole(title: 'Remove');
      });
      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes())
                .thenAnswer((_) => piholes..remove(pihole));
            when(repository.remove(pihole)).thenAnswer((_) =>
                Future.value(true));
            when(repository.active()).thenAnswer((_) => piholes.first);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(
                      all: piholes..remove(pihole), active: piholes.first),
                ]));

            piholeBloc.dispatch(RemovePihole(Pihole()));
          });

      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateError] when pihole repository throws PiholeException',
              () {
            when(repository.remove(pihole)).thenThrow(PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(RemovePihole(pihole));
          });
    });

    group('activatePihole', () {
      setUp(() {
        pihole = piholes.last;
      });
      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes()).thenAnswer((_) => piholes);
            when(repository.activate(pihole)).thenAnswer((_) =>
                Future.value(true));
            when(repository.active()).thenAnswer((_) => piholes.last);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(all: piholes, active: piholes.last),
                ]));

            piholeBloc.dispatch(ActivatePihole(pihole));
          });

      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateError] when pihole repository throws PiholeException',
              () {
            when(repository.activate(pihole)).thenThrow(PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(ActivatePihole(pihole));
          });
    });

    group('updatePihole', () {
      Pihole original;
      Pihole update;

      setUp(() {
        original = piholes.first;
        update = Pihole(title: 'Update');
      });
      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateSuccess] when repository returns Pihole',
              () {
            when(repository.getPiholes()).thenAnswer((_) => piholes);
            when(repository.update(original, update))
                .thenAnswer((_) => Future.value(true));
            when(repository.active()).thenAnswer((_) => update);

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateSuccess(
                      all: piholes
                        ..remove(original)
                        ..add(update),
                      active: update),
                ]));

            piholeBloc.dispatch(
                UpdatePihole(original: original, update: update));
          });

      test(
          'emits [PiholetateEmpty, PiholetateLoading, PiholetateError] when pihole repository throws PiholeException',
              () {
            when(repository.update(original, update)).thenThrow(
                PiholeException());

            expectLater(
                piholeBloc.state,
                emitsInOrder([
                  PiholeStateEmpty(),
                  PiholeStateLoading(),
                  PiholeStateError(PiholeException()),
                ]));

            piholeBloc.dispatch(
                UpdatePihole(original: original, update: update));
          });
    });
  });

  group('repository', () {
    MockSecureStore secureStore;
    PiholeRepository piholeRepository;

//    setUpAll(() {
//      Globals.client = MockPiholeClient();
//    });

    setUp(() {
      secureStore = MockSecureStore();
      piholeRepository = PiholeRepository(secureStore);
    });

    test('getPiholes', () {
      final map = mockPiholes
          .asMap()
          .map((_, pihole) => MapEntry<String, Pihole>(pihole.title, pihole));
      secureStore.piholes = map;

      expect(piholeRepository.getPiholes(), map.values);
    });

    test('active', () {
      secureStore.active = mockPiholes.first;
      expect(piholeRepository.active(), mockPiholes.first);
    });

    group('add', () {
      Pihole pihole;

      setUp(() {
        pihole = Pihole();
      });

      test('valid add returns', () {
        when(secureStore.add(pihole)).thenAnswer((_) => Future.value(true));
        expect(piholeRepository.add(pihole), completion(isTrue));
      });
    });

    test('remove', () {
      final pihole = mockPiholes.first;
      when(secureStore.remove(pihole)).thenAnswer((_) => Future.value(true));
      expect(piholeRepository.remove(pihole), completion(isTrue));
    });

    test('activate', () {
      final pihole = mockPiholes.first;
      when(secureStore.activate(pihole)).thenAnswer((_) => Future.value(true));
      Globals.fetchForAll = () {};
      expect(piholeRepository.activate(pihole), completes);
    });

    test('update', () {
      final original = mockPiholes.first;
      final update = Pihole(title: 'update');
      when(secureStore.update(original, update))
          .thenAnswer((_) => Future.value(true));
      expect(piholeRepository.update(original, update), completes);
    });

    test('reset', () {
      when(secureStore.deleteAll()).thenAnswer((_) => Future.value(true));
      when(secureStore.add(any)).thenAnswer((_) => Future.value(true));
      when(secureStore.reload()).thenAnswer((_) => Future.value(true));
      expect(piholeRepository.reset(), completes);
    });
  });
}

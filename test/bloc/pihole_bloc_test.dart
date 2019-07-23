import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockPiholeRepository extends Mock implements PiholeRepository {}

main() {
  MockPiholeRepository repository;
  PiholeBloc piholeBloc;

  setUp(() {
    repository = MockPiholeRepository();
    piholeBloc = PiholeBloc(repository);
  });

  test('has a correct initialState', () {
    expect(piholeBloc.initialState, PiholeStateEmpty());
  });

  group('fetchPiholes', () {
    test(
        'emits [PiholeStateEmpty, PiholeStateLoading, PiholeStateSuccess] when repository returns Pihole',
        () {
      when(repository.getPiholes()).thenAnswer((_) => mockPiholes);
      when(repository.active()).thenAnswer((_) => mockPiholes.first);

      expectLater(
          piholeBloc.state,
          emitsInOrder([
            PiholeStateEmpty(),
            PiholeStateLoading(),
            PiholeStateSuccess(all: mockPiholes, active: mockPiholes.first),
          ]));

      piholeBloc.dispatch(FetchPiholes());
    });
  });
}

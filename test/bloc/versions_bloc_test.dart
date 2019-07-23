import 'package:flutterhole/bloc/versions/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mock.dart';

class MockVersionsRepository extends Mock implements VersionsRepository {}

main() {
  MockVersionsRepository versionsRepository;
  VersionsBloc versionsBloc;

  setUp(() {
    versionsRepository = MockVersionsRepository();
    versionsBloc = VersionsBloc(versionsRepository);
  });

  test('has a correct initialState', () {
    expect(versionsBloc.initialState, VersionsStateEmpty());
  });

  group('FetchVersions', () {
    test(
        'emits [VersionsStateEmpty, VersionsStateLoading, VersionsStateSuccess] when repository returns Versions',
        () {
      when(versionsRepository.getVersions())
          .thenAnswer((_) => Future.value(mockVersions));

      expectLater(
          versionsBloc.state,
          emitsInOrder([
            VersionsStateEmpty(),
            VersionsStateLoading(),
            VersionsStateSuccess(mockVersions),
          ]));

      versionsBloc.dispatch(FetchVersions());
    });

    test(
        'emits [VersionsStateEmpty, VersionsStateLoading, VersionsStateError] when home repository throws PiholeException',
        () {
      when(versionsRepository.getVersions()).thenThrow(PiholeException());

      expectLater(
          versionsBloc.state,
          emitsInOrder([
            VersionsStateEmpty(),
            VersionsStateLoading(),
            VersionsStateError(e: PiholeException()),
          ]));

      versionsBloc.dispatch(FetchVersions());
    });
  });
}

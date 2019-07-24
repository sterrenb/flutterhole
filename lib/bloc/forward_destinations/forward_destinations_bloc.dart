import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole/bloc/forward_destinations/bloc.dart';
import 'package:flutterhole/service/pihole_exception.dart';

class ForwardDestinationsBloc
    extends Bloc<ForwardDestinationsEvent, ForwardDestinationsState> {
  final ForwardDestinationsRepository forwardDestinationsRepository;

  ForwardDestinationsBloc(this.forwardDestinationsRepository);

  @override
  ForwardDestinationsState get initialState => ForwardDestinationsStateEmpty();

  @override
  Stream<ForwardDestinationsState> mapEventToState(
    ForwardDestinationsEvent event,
  ) async* {
    if (event is FetchForwardDestinations) yield* _fetch();
  }

  Stream<ForwardDestinationsState> _fetch() async* {
    yield ForwardDestinationsStateLoading();
    try {
      final forwardDestinations =
          await forwardDestinationsRepository.getForwardDestinations();
      yield ForwardDestinationsStateSuccess(forwardDestinations);
    } on PiholeException catch (e) {
      yield ForwardDestinationsStateError(e: e);
    }
  }
}

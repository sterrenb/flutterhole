import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutterhole_again/repository/summary_repository.dart';
import 'package:flutterhole_again/service/pihole_exception.dart';

import './bloc.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final SummaryRepository summaryRepository;

  SummaryBloc(this.summaryRepository);

  @override
  SummaryState get initialState => SummaryStateEmpty();

  @override
  Stream<SummaryState> mapEventToState(
    SummaryEvent event,
  ) async* {
    if (event is FetchSummary) yield* _fetch();
  }

  Stream<SummaryState> _fetch() async* {
    yield SummaryStateLoading();
    try {
      final summary = await summaryRepository.getSummary();
      yield SummaryStateSuccess(summary);
    } on PiholeException catch (e) {
      yield SummaryStateError(errorMessage: e.message);
    }
  }
}

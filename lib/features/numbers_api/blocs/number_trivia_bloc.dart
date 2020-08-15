import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterhole/core/models/failures.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/numbers_api/data/repositories/numbers_api_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'number_trivia_bloc.freezed.dart';

@freezed
abstract class NumberTriviaState with _$NumberTriviaState {
  const factory NumberTriviaState.initial() = NumberTriviaStateInitial;

  const factory NumberTriviaState.loading() = NumberTriviaStateLoading;

  const factory NumberTriviaState.success(Map<int, String> trivia) =
      NumberTriviaStateSuccess;

  const factory NumberTriviaState.failure(Failure failure) =
      NumberTriviaStateFailure;
}

@freezed
abstract class NumberTriviaEvent with _$NumberTriviaEvent {
  const factory NumberTriviaEvent.fetchMany(List<int> integers) =
      NumberTriviaEventFetchMany;
}

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  NumberTriviaBloc([NumbersApiRepository numbersApiRepository])
      : _numbersApiRepository =
            numbersApiRepository ?? getIt<NumbersApiRepository>(),
        super(NumberTriviaState.initial());

  final NumbersApiRepository _numbersApiRepository;

  Stream<NumberTriviaState> _fetchMany(List<int> integers) async* {
    yield NumberTriviaState.loading();

    final result = await _numbersApiRepository.fetchManyTrivia(integers);

    yield* result.fold(
      (failure) async* {
        yield NumberTriviaState.failure(failure);
      },
      (trivia) async* {
        yield NumberTriviaState.success(trivia);
      },
    );
  }

  @override
  Stream<NumberTriviaState> mapEventToState(NumberTriviaEvent event) async* {
    if (event is NumberTriviaEventFetchMany) yield* _fetchMany(event.integers);
  }
}

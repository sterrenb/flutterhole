import 'package:flutterhole_web/features/entities/api_entities.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sumProvider = Provider.autoDispose<AsyncValue<PiSummary>>((ref) {
  final pi = ref.watch(simplePiProvider);
  return ref.watch(piSummaryProvider(pi));
});

final sumStreamProvider = StreamProvider.autoDispose<PiSummary>((ref) async* {
  final pi = ref.watch(simplePiProvider);
  print('getting summary in stream');
  final x = await ref.watch(piSummaryProvider(pi).future);
  yield x;
});

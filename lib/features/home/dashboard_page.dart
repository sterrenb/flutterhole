import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/home/dashboard_tiles.dart';
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

class DashboardPage extends HookWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing'),
      ),
      body: HookBuilder(builder: (context) {
        return ListView(
          children: [
            TotalQueriesTile(),
            QueriesBlockedTile(),
            ElevatedButton(
                onPressed: () {
                  context.refresh(
                      piSummaryProvider(context.read(simplePiProvider)));
                  // context.refresh(sumStreamProvider);
                },
                child: Text('Refresh')),
          ],
        );
      }),
    );
  }
}

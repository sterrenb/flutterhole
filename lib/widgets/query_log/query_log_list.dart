import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QueryLogList extends HookConsumerWidget {
  const QueryLogList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Query $index'),
          );
        });
  }
}

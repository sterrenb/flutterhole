import 'package:flutter/material.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';
import 'package:flutterhole/widget/memory_tree_builder.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Logs',
      body: MemoryTreeBuilder(
        tree: Globals.tree,
      ),
    );
  }
}

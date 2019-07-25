import 'package:flutter/material.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/widget/layout/memory_tree_builder.dart';
import 'package:flutterhole/widget/layout/scaffold.dart';

class LogScreen extends StatelessWidget {
  final _memoryTreeBuilder = MemoryTreeBuilder(tree: Globals.tree);

  @override
  Widget build(BuildContext context) {
    return DefaultScaffold(
      title: 'Internal Log',
      actions: <Widget>[_CopyButton(memoryTreeBuilder: _memoryTreeBuilder)],
      body: _memoryTreeBuilder,
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({
    Key key,
    @required MemoryTreeBuilder memoryTreeBuilder,
  })
      : _memoryTreeBuilder = memoryTreeBuilder,
        super(key: key);

  final MemoryTreeBuilder _memoryTreeBuilder;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () {
        _memoryTreeBuilder.copyToClipboard();
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Copied to clipboard')));
      },
      tooltip: 'Copy to clipboard',
    );
  }
}

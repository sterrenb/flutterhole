import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshableBuilder extends StatefulWidget {
  const RefreshableBuilder({
    Key? key,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  final VoidFutureCallBack onRefresh;
  final Widget child;

  @override
  _RefreshableBuilderState createState() => _RefreshableBuilderState();
}

class _RefreshableBuilderState extends State<RefreshableBuilder> {
  final refreshController = RefreshController();

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  Future<void> onRefresh() async {
    try {
      await widget.onRefresh();
      refreshController.refreshCompleted();
    } catch (e) {
      refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      onRefresh: onRefresh,
      enablePullDown: true,
      child: widget.child,
    );
  }
}

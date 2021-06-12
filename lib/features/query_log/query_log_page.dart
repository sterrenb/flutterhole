import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/layout/app_drawer.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef Future<void> RefreshCallback(RefreshController controller);

class _RefreshableQueryItemList extends StatefulWidget {
  const _RefreshableQueryItemList({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.onLoadMore,
  }) : super(key: key);

  final Widget child;
  final VoidFutureCallBack onRefresh;
  final VoidFutureCallBack onLoadMore;

  @override
  __RefreshableQueryItemListState createState() =>
      __RefreshableQueryItemListState();
}

class __RefreshableQueryItemListState extends State<_RefreshableQueryItemList> {
  final RefreshController controller = RefreshController();

  void onRefresh() async {
    print('refreshing');
    await widget.onRefresh();
    controller.refreshCompleted();
  }

  void onLoading() async {
    print('loading');
    await Future.delayed(Duration(seconds: 1));
    await widget.onLoadMore();
    if (controller.position != null) {
      print('almost animating');
      await Future.delayed(kThemeAnimationDuration);
      await controller.position!.animateTo(
        controller.position!.maxScrollExtent - 50.0,
        duration: kThemeAnimationDuration,
        curve: Curves.ease,
      );
    }
    controller.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: ClassicFooter(),
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: widget.child,
    );
  }
}

class QueryLogPage extends HookWidget {
  const QueryLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryItems = useProvider(queryLogNotifierProvider);
    final maxResults = useState(10);

    useEffect(() {
      context
          .read(queryLogNotifierProvider.notifier)
          .fetchItems(maxResults.value);
    }, [piholeStatusNotifierProvider]);

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Query log (${queryItems.length})'),
        actions: [
          IconButton(
              onPressed: () {
                // context
                //     .read(piholeRepositoryProvider)
                //     .fetchQueryItems(context.read(activePiProvider).state);
                context.read(queryLogNotifierProvider.notifier).fetchItems();
                // context.read(queryLogNotifierProvider.notifier).addDummy();
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: Scrollbar(
        child: _RefreshableQueryItemList(
          onRefresh: () async {
            await context
                .read(queryLogNotifierProvider.notifier)
                .fetchItems(maxResults.value);
          },
          onLoadMore: () async {
            maxResults.value += 10;
            await context
                .read(queryLogNotifierProvider.notifier)
                .fetchItems(maxResults.value);
          },
          // child: QueryLogListView(
          //   fetchForPage: (pageKey) {
          //     return context
          //         .read(queryLogNotifierProvider.notifier)
          //         .fetchMore(pageKey);
          //   },
          // ),
          child: ListView.builder(
              itemCount: queryItems.length,
              itemBuilder: (context, index) {
                final item = queryItems.elementAt(index);
                return QueryItemTile(item: item);
              }),
        ),
      ),
    );
  }
}

class QueryLogListView extends StatefulWidget {
  const QueryLogListView({Key? key, required this.fetchForPage})
      : super(key: key);

  final FetchForPage fetchForPage;

  @override
  _QueryLogListViewState createState() => _QueryLogListViewState();
}

typedef Future<List<QueryItem>> FetchForPage(int pageKey);

class _QueryLogListViewState extends State<QueryLogListView> {
  final PagingController<int, QueryItem> _pagingController =
      PagingController(firstPageKey: DateTime.now().millisecondsSinceEpoch);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchPage(int pageKey) async {
    // print('fetching for $pageKey');
    try {
      final result = await widget.fetchForPage(pageKey);
      print(
          '${result.last.pageKey} (${result.last.timestamp.millisecondsSinceEpoch / 1000})');
      _pagingController.appendPage(result, result.last.pageKey);
    } catch (e) {
      _pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedListView(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<QueryItem>(
          itemBuilder: (context, item, index) {
        return QueryItemTile(item: item);
      }),
    );
  }
}

class QueryItemTile extends StatelessWidget {
  const QueryItemTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  final QueryItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      title: Text(item.domain),
      subtitle: Text(
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp)}\nWow'),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/formatting/entity_formatting.dart';
import 'package:flutterhole_web/features/layout/error_builders.dart';
import 'package:flutterhole_web/features/logging/log_widgets.dart';
import 'package:flutterhole_web/features/pihole/pihole_providers.dart';
import 'package:flutterhole_web/features/query_log/query_log_widgets.dart';
import 'package:flutterhole_web/features/settings/active_providers.dart';
import 'package:flutterhole_web/features/settings/developer_widgets.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pihole_api/pihole_api.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class _Bottom extends HookWidget implements PreferredSizeWidget {
  const _Bottom({
    Key? key,
    required this.lastRefresh,
    required this.searchTerm,
  })  : preferredSize = const Size.fromHeight(_height + 2.0),
        super(key: key);

  static const double _height = 34.0;

  @override
  final Size preferredSize;

  final DateTime lastRefresh;
  final String searchTerm;

  @override
  Widget build(BuildContext context) {
    final queryLogMax = useProvider(queryLogMaxProvider);
    final filteredValue = useProvider(searchedQueryLogProvider(searchTerm));
    final captionStyle = Theme.of(context)
        .textTheme
        .caption!
        .copyWith(color: Theme.of(context).colorScheme.onPrimary);
    return Container(
      height: _height,
      // color: Theme.of(context).accentColor,
      color: Theme.of(context).primaryColor,
      child: filteredValue.maybeWhen(
        data: (queries) => SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${queries.length}/${queryLogMax.state} queries',
                  style: captionStyle),
              Row(
                children: [
                  Text('Refreshed ', style: captionStyle),
                  DifferenceText(
                    lastRefresh,
                    textStyle: captionStyle,
                  ),
                ],
              )
            ],
          ),
        ),
        orElse: () => Container(),
      ),
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField(
    this.controller,
    this.node, {
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode node;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: node,
      style: Theme.of(context)
          .textTheme
          .headline6!
          .copyWith(color: Theme.of(context).colorScheme.onPrimary),
      cursorColor: Theme.of(context).colorScheme.onPrimary,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: ' Search...',
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}

class QueryLogPage extends HookWidget {
  const QueryLogPage({Key? key}) : super(key: key);

  static const String _title = 'Query log';

  @override
  Widget build(BuildContext context) {
    final refreshController = useState(RefreshController());
    final scrollController = useScrollController();
    final lastRefresh = useState(DateTime.now());
    final searchController = useTextEditingController();
    final searchNode = useFocusNode(debugLabel: 'searchNode');
    final isSearching = useState(false);
    final searchTerm = useState('');
    final filteredValue =
        useProvider(searchedQueryLogProvider(searchTerm.value));

    void onRefresh() async {
      context.refresh(queryLogProvider(context.read(activePiParamsProvider)));
      refreshController.value.refreshCompleted();
    }

    useEffect(() {
      searchController.addListener(() {
        searchTerm.value = searchController.text;
      });
    }, [searchController]);

    useEffect(() {
      filteredValue.whenData((_) {
        lastRefresh.value = DateTime.now();
      });
    }, [filteredValue]);

    Widget buildPopupMenuItemChild(String title, IconData iconData) => Row(
          children: [
            Icon(
              iconData,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12.0),
            Text(title),
          ],
        );

    return WillPopScope(
      onWillPop: () async {
        if (isSearching.value && searchController.text.isNotEmpty) {
          FocusScope.of(context).requestFocus(FocusNode());
          isSearching.value = false;
          searchController.text = '';
          return false;
        }

        return true;
      },
      child: ActivePiTheme(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Visibility(
                      visible: isSearching.value,
                      maintainState: true,
                      child: _SearchTextField(searchController, searchNode)),
                  Visibility(
                    visible:
                        !isSearching.value && searchController.text.isEmpty,
                    child: const Text(_title),
                  ),
                ],
              ),
              bottom: _Bottom(
                lastRefresh: lastRefresh.value,
                searchTerm: searchTerm.value,
              ),
              actions: [
                AnimatedSwitcher(
                  duration: kThemeAnimationDuration,
                  child: isSearching.value
                      ? IconButton(
                          key: const ValueKey('cancel'),
                          tooltip: 'Cancel search',
                          onPressed: () {
                            searchController.text = '';
                            isSearching.value = false;
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          icon: const Icon(KIcons.cancel))
                      : IconButton(
                          key: const ValueKey('search'),
                          tooltip: 'Search queries',
                          onPressed: () {
                            FocusScope.of(context).requestFocus(searchNode);
                            isSearching.value = true;
                          },
                          icon: const Icon(KIcons.search)),
                ),
                const ThemeModeToggle(),
                PopupMenuButton<String>(
                  onSelected: (String selected) async {
                    if (selected == 'filters') {
                      showModal(
                          context: context,
                          builder: (context) => const QueryLogFiltersDialog());
                      return;
                    }

                    if (selected == 'max_results') {
                      final update = await showModal<int>(
                          context: context,
                          builder: (context) => const MaxResultsDialog());

                      if (update != null) {
                        context.read(queryLogMaxProvider).state = update;
                      }
                      return;
                    }

                    if (selected == 'refresh') {
                      context.refresh(queryLogProvider(
                          context.read(activePiParamsProvider)));
                      return;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'refresh',
                      child: buildPopupMenuItemChild('Refresh', KIcons.refresh),
                    ),
                    PopupMenuItem(
                      value: 'filters',
                      child: buildPopupMenuItemChild('Filters', KIcons.filter),
                    ),
                    PopupMenuItem(
                      value: 'max_results',
                      child: buildPopupMenuItemChild(
                          'Max results', KIcons.upperLimit),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: Stack(
              children: [
                _NavigateToTopFab(scrollController: scrollController),
                _NavigateToBottomFab(scrollController: scrollController),
              ],
            ),
            body: Scrollbar(
              child: SmartRefresher(
                  controller: refreshController.value,
                  onRefresh: onRefresh,
                  child: filteredValue.when(
                    data: (queries) {
                      return ListView.builder(
                        controller: scrollController,
                        // shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        // itemCount: 10,
                        itemCount: queries.length,
                        itemBuilder: (context, index) =>
                            QueryItemTile(queries.elementAt(index)),
                      );
                    },
                    loading: () => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    ),
                    error: (e, s) => CenteredErrorMessage(
                      e,
                      s,
                      message: 'Fetching queries failed.',
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigateToBottomFab extends HookWidget {
  const _NavigateToBottomFab({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);
    useEffect(() {
      scrollController.addListener(() {
        if (scrollController.position.pixels > 100 &&
            scrollController.position.userScrollDirection ==
                ScrollDirection.reverse) {
          visible.value = true;
        } else {
          visible.value = false;
        }
      });
    }, [scrollController]);

    return IgnorePointer(
      ignoring: !visible.value,
      child: AnimatedOpacity(
        duration: kThemeChangeDuration,
        opacity: visible.value ? 1.0 : 0.0,
        curve: Curves.ease,
        child: FloatingActionButton(
          heroTag: 'fab_bottom',
          elevation: 0.0,
          tooltip: 'Navigate to bottom',
          child: const Icon(KIcons.bottom),
          onPressed: () async {
            scrollController
                .jumpTo(scrollController.position.maxScrollExtent - 50);

            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: kThemeChangeDuration,
              curve: Curves.easeOut,
            );

            return;
          },
        ),
      ),
    );
  }
}

class _NavigateToTopFab extends HookWidget {
  const _NavigateToTopFab({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final visible = useState(false);
    useEffect(() {
      scrollController.addListener(() {
        if (scrollController.position.pixels > 500 &&
            scrollController.position.userScrollDirection ==
                ScrollDirection.forward) {
          visible.value = true;
        } else {
          visible.value = false;
        }
      });
    }, [scrollController]);

    return IgnorePointer(
      ignoring: !visible.value,
      child: AnimatedOpacity(
        duration: kThemeChangeDuration,
        opacity: visible.value ? 1.0 : 0.0,
        curve: Curves.ease,
        child: FloatingActionButton(
          heroTag: 'fab_top',
          elevation: 0.0,
          tooltip: 'Navigate to top',
          child: const Icon(KIcons.top),
          onPressed: () async {
            scrollController.jumpTo(50);

            scrollController.animateTo(
              0,
              duration: kThemeChangeDuration,
              curve: Curves.easeOut,
            );

            return;
          },
        ),
      ),
    );
  }
}

class MaxResultsDialog extends HookWidget {
  const MaxResultsDialog({Key? key}) : super(key: key);

  static const List<int> values = [100, 500, 2500, 5000, 10000];

  @override
  Widget build(BuildContext context) {
    final x = useState(context.read(queryLogMaxProvider).state);
    return DialogBase(
      header: const DialogHeader(
        title: 'Max results',
        message: 'The maximum amount of queries to fetch.',
      ),
      body: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values.elementAt(index);
          return RadioListTile<int>(
            value: value,
            groupValue: x.value,
            title: Text(numberFormat.format(value)),
            onChanged: (update) {
              if (update != null) {
                x.value = update;
              }
            },
          );
        },
      ),
      onSelect: () {
        Navigator.of(context).pop(x.value);
      },
      theme: Theme.of(context),
    );
  }
}

final queryLogFilterProvider = StateProvider<List<QueryStatus>>((ref) {
  return QueryStatus.values.toList();
});

final filteredQueryLogProvider =
    Provider.autoDispose<AsyncValue<List<QueryItem>>>((ref) {
  final x = ref.watch(activeQueryLogProvider);
  final filters = ref.watch(queryLogFilterProvider).state;
  return x.whenData((input) =>
      input.where((element) => filters.contains(element.queryStatus)).toList());
});

final searchedQueryLogProvider = Provider.autoDispose
    .family<AsyncValue<List<QueryItem>>, String>((ref, search) {
  final x = ref.watch(filteredQueryLogProvider);

  if (search.isEmpty) return x;

  return x.whenData((value) => value
      .where((element) =>
          element.domain.toLowerCase().contains(search.toLowerCase()))
      .toList());
});

class QueryLogFiltersDialog extends HookWidget {
  const QueryLogFiltersDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = useProvider(queryLogFilterProvider);

    Widget buildSingleStatusBox(String title, QueryStatus status) =>
        _CheckBoxTile(
          title: Text(title),
          leading: Icon(
            status.iconData,
            color: status.toColor(),
          ),
          value: current.state.contains(status),
          onAdd: () => current.state = [...current.state..add(status)],
          onRemove: () => current.state = [
            ...current.state..removeWhere((element) => element == status)
          ],
        );

    Widget buildManyStatusBox(String title, List<QueryStatus> statuses) =>
        _CheckBoxTile(
          title: Text(title),
          leading: Icon(
            statuses.first.iconData,
            color: statuses.first.toColor(),
          ),
          value: current.state.contains(statuses.first),
          onAdd: () => current.state = [
            ...current.state
              ..addAll(
                  statuses.skipWhile((value) => current.state.contains(value)))
          ],
          onRemove: () => current.state = [
            ...current.state
              ..removeWhere((element) => statuses.contains(element))
          ],
        );

    return DialogListBase(
      header: const DialogHeader(
        title: 'Filters',
        message: 'Show queries based on their status.',
      ),
      body: SliverList(
        delegate: SliverChildListDelegate.fixed([
          buildSingleStatusBox('Forwarded', QueryStatus.Forwarded),
          buildManyStatusBox('Blocked', [
            QueryStatus.BlockedWithGravity,
            QueryStatus.BlockedWithRegexWildcard,
            QueryStatus.BlockedWithBlacklist,
            QueryStatus.BlockedWithExternalIP,
            QueryStatus.BlockedWithExternalNull,
            QueryStatus.BlockedWithExternalNXRA,
          ]),
          buildSingleStatusBox('Cached', QueryStatus.Cached),
          buildSingleStatusBox('Unknown', QueryStatus.Unknown),
        ]),
      ),
    );
  }
}

class _CheckBoxTile extends StatelessWidget {
  const _CheckBoxTile({
    Key? key,
    required this.title,
    required this.leading,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  final Widget title;
  final Widget leading;
  final bool value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (update) {
        if (update == true) {
          return onAdd();
        } else {
          return onRemove();
        }
      },
      title: title,
      secondary: leading,
    );
  }
}

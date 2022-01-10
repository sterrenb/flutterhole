import 'package:flutter/material.dart';
import 'package:flutterhole/views/base_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef TabViewBuilder = Widget Function(BuildContext, PageController);

final _tabViewIndexProvider = StateProvider<int>((ref) => 0);
final tabViewIndexProvider = StateProvider<int>((ref) => 0);

class TabView extends HookConsumerWidget {
  const TabView({
    Key? key,
    required this.bottomItems,
    required this.builder,
    this.floatingActionButton,
    this.appBar,
  }) : super(key: key);

  final List<BottomNavigationBarItem> bottomItems;
  final TabViewBuilder builder;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_tabViewIndexProvider);
    final PageController page = usePageController(initialPage: currentIndex);

    useValueChanged<int, void>(currentIndex, (oldValue, _) {
      page.animateToPage(
        currentIndex,
        duration: kThemeAnimationDuration * (oldValue - currentIndex).abs(),
        curve: Curves.easeOutCubic,
      );
    });

    useEffect(() {
      page.addListener(() {
        if (page.page != null) {
          ref.read(tabViewIndexProvider.notifier).state = page.page!.round();
        }
      });
    }, [page]);

    return BaseView(
      child: Scaffold(
        appBar: appBar,
        body: builder(context, page),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(_tabViewIndexProvider.notifier).state = index;
          },
          landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
          items: bottomItems,
        ),
      ),
    );
  }
}

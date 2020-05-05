import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/blocs/home_bloc.dart';
import 'package:flutterhole/widgets/layout/default_drawer.dart';
import 'package:flutterhole/widgets/pages/clients_page_view.dart';
import 'package:flutterhole/widgets/pages/domains_page_view.dart';
import 'package:flutterhole/widgets/pages/summary_page_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemSelected(int index) {
    _onPageChanged(index);
    _pageController.animateToPage(
      index,
      duration: kThemeAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => HomeBloc(),
      child: Scaffold(
        drawer: DefaultDrawer(),
        appBar: AppBar(
          title: Text('Flutter'),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemSelected,
          items: [
            BottomNavyBarItem(
              icon: Icon(KIcons.summary),
              title: Text('Summary'),
              activeColor: KColors.summary,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(KIcons.clients),
              title: Text('Clients'),
              activeColor: KColors.clients,
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(KIcons.domains),
              title: Text('Domains'),
              activeColor: KColors.domains,
              textAlign: TextAlign.center,
            ),
//          BottomNavyBarItem(
//            icon: Icon(KIcons.settings),
//            title: Text('Settings'),
//            activeColor: KColors.settings,
//            textAlign: TextAlign.center,
//          ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: <Widget>[
            SummaryPageView(),
            ClientsPageView(),
            DomainsPageView(),
          ],
        ),
      ),
    );
  }
}

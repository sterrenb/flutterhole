import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/home/blocs/home_bloc.dart';
import 'package:flutterhole/features/home/presentation/pages/clients/clients_page_view.dart';
import 'package:flutterhole/features/home/presentation/pages/domains/domains_page_view.dart';
import 'package:flutterhole/features/home/presentation/pages/summary/summary_page_view.dart';
import 'package:flutterhole/features/numbers_api/blocs/number_trivia_bloc.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/pi_connection_toggle_button.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/features/settings/presentation/widgets/active_pihole_title.dart';
import 'package:flutterhole/features/settings/presentation/widgets/pihole_theme_builder.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';

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
    return PiholeThemeBuilder(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
            create: (_) => HomeBloc()..add(HomeEvent.fetch()),
          ),
          BlocProvider<NumberTriviaBloc>(
            create: (_) => NumberTriviaBloc(),
          ),
        ],
        child: Builder(
          builder: (context) {
            return BlocListener<HomeBloc, HomeState>(
              listener: (context, state) {
                final bool enableTrivia =
                    getIt<PreferenceService>().get(KPrefs.useNumbersApi);

                if (enableTrivia) {
                  state.maybeMap(
                      success: (state) {
                        state.summary.fold(
                          (failure) {},
                          (summary) {
                            BlocProvider.of<NumberTriviaBloc>(context)
                                .add(NumberTriviaEvent.fetchMany([
                              summary.dnsQueriesToday,
                              summary.adsBlockedToday,
                              summary.adsPercentageToday.round(),
                              summary.domainsBeingBlocked,
                            ]));
                          },
                        );
                      },
                      orElse: () {});
                }
              },
              child: Scaffold(
                drawer: DefaultDrawer(),
                appBar: AppBar(
                  elevation: 0.0,
                  title: ActivePiholeTitle(),
                  actions: <Widget>[
                    Visibility(
                      visible: false,
                      child: IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          BlocProvider.of<HomeBloc>(context)
                              .add(HomeEvent.fetch());
                        },
                      ),
                    ),
                    PiConnectionToggleButton(),
                  ],
                ),
                bottomNavigationBar: BottomNavyBar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onItemSelected,
                  curve: Curves.easeInOut,
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
                  ],
                ),
                body: PageView(
//                  physics: const BouncingScrollPhysics(),
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
          },
        ),
      ),
    );
  }
}

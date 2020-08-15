import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/blacklist_item.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/string_search_notifier.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_bloc_listener.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_page_overflow_refresher.dart';
import 'package:flutterhole/features/routing/presentation/pages/page_scaffold.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:flutterhole/widgets/layout/notifications/snackbars.dart';
import 'package:provider/provider.dart';

class BlacklistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StringSearchNotifier>(
      create: (_) => StringSearchNotifier(),
      child: PageScaffold(
        drawer: DefaultDrawer(),
        appBar: AppBar(
          title: Text('Blacklist'),
          elevation: 0.0,
          actions: [
            _AddToBlacklistButton(),
          ],
        ),
        body: ListBlocListener(
          child: Builder(
            builder: (BuildContext context) => Scrollbar(
              child: ListPageOverflowRefresher(
                child: BlocBuilder<ListBloc, ListBlocState>(
                    builder: (context, state) {
                  if (state.failureOption.isSome()) {
                    return CenteredFailureIndicator(
                        state.failureOption.fold(() => null, (a) => a));
                  }

                  if (state.blacklist != null) {
                    return ListView.builder(
                      itemCount: state.blacklist.data.length,
                      itemBuilder: (context, index) {
                        final BlacklistItem blacklistItem =
                            state.blacklist.data.elementAt(index);
                        return Slidable(
                          key: Key(blacklistItem.domain),
                          actionPane: const SlidableDrawerActionPane(),
                          secondaryActions: [
                            IconSlideAction(
                              caption: 'Delete',
                              color: KColors.blocked,
                              icon: KIcons.delete,
                              onTap: () {
                                showInfoSnackBar(context,
                                    'Deleting ${blacklistItem.domain}...');

                                BlocProvider.of<ListBloc>(context).add(
                                    ListBlocEvent.removeFromBlacklist(
                                        blacklistItem));
                              },
                            )
                          ],
                          child: ListTile(
                            title: Text('${blacklistItem.domain}'),
                            subtitle: blacklistItem.comment != null
                                ? Text('${blacklistItem.comment}')
                                : null,
                            trailing: Icon(
                              KIcons.connectionStatus,
                              size: 8.0,
                              color: blacklistItem.isEnabled
                                  ? KColors.success
                                  : KColors.blocked,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return CenteredLoadingIndicator();
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddToBlacklistButton extends StatefulWidget {
  const _AddToBlacklistButton({
    Key key,
  }) : super(key: key);

  @override
  __AddToBlacklistButtonState createState() => __AddToBlacklistButtonState();
}

class __AddToBlacklistButtonState extends State<_AddToBlacklistButton> {
  TextEditingController _searchEditingController;
  PersistentBottomSheetController _persistentBottomSheetController;
  bool _isWildcard = false;

  @override
  void initState() {
    super.initState();
    _searchEditingController = TextEditingController();
    _searchEditingController.addListener(() {
      setState(() {
        Provider.of<StringSearchNotifier>(context, listen: false).searchQuery =
            _searchEditingController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StringSearchNotifier>(builder: (
      BuildContext context,
      StringSearchNotifier notifier,
      _,
    ) {
      return IconButton(
        tooltip: 'Add to blacklist',
        icon: Icon(KIcons.add),
        onPressed: () {
          setState(() {
            notifier.startSearching();
            _isWildcard = false;
            _persistentBottomSheetController =
                Scaffold.of(context).showBottomSheet((context) => WillPopScope(
                      onWillPop: () async {
                        notifier.stopSearching();
                        return true;
                      },
                      child: Builder(
                        builder: (context) => Container(
                          color: Theme.of(context).cardColor,
                          child: SafeArea(
                            minimum: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    autofocus: true,
                                    keyboardType: TextInputType.url,
                                    onSubmitted: (String value) {
                                      final String domain = _isWildcard
                                          ? '$wildcardPrefix$value$wildcardSuffix'
                                          : value;
                                      BlocProvider.of<ListBloc>(context).add(
                                          ListBlocEvent.addToBlacklist(
                                              domain, _isWildcard));
                                      Navigator.pop(context);
                                      showInfoSnackBar(
                                          context, 'Adding ${domain}...');
                                    },
                                    decoration: InputDecoration(
                                      prefixText:
                                          _isWildcard ? wildcardPrefix : null,
                                      suffixText:
                                          _isWildcard ? wildcardSuffix : null,
                                      border: InputBorder.none,
                                      hintText: 'Add to blacklist',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Row(
                                  children: [
                                    Text(
                                      'Wildcard',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    Checkbox(
                                      value: _isWildcard,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _isWildcard = value;
                                          _persistentBottomSheetController
                                              .setState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
          });
        },
      );
    });
  }
}

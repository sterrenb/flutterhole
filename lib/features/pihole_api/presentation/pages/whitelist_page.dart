import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:flutterhole/features/pihole_api/presentation/notifiers/string_search_notifier.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_bloc_listener.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_page_overflow_refresher.dart';
import 'package:flutterhole/features/routing/presentation/pages/page_scaffold.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';
import 'package:provider/provider.dart';

class WhitelistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StringSearchNotifier>(
      create: (_) => StringSearchNotifier(),
      child: PageScaffold(
        drawer: DefaultDrawer(),
        appBar: AppBar(
          title: Text('Whitelist'),
          elevation: 0.0,
          actions: [
            _AddToWhitelistButton(),
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

                  if (state.whitelist != null) {
                    return ListView.builder(
                      itemCount: state.whitelist.data.length,
                      itemBuilder: (context, index) {
                        final WhitelistItem whitelistItem =
                            state.whitelist.data.elementAt(index);
                        return Slidable(
                          key: Key(whitelistItem.domain),
                          actionPane: const SlidableDrawerActionPane(),
                          secondaryActions: [
                            IconSlideAction(
                              caption: 'Delete',
                              color: KColors.blocked,
                              icon: KIcons.delete,
                              onTap: () {
                                BlocProvider.of<ListBloc>(context).add(
                                    ListBlocEvent.removeFromWhitelist(
                                        whitelistItem));
                              },
                            )
                          ],
                          child: ListTile(
                            title: Text('${whitelistItem.domain}'),
                            subtitle: whitelistItem.comment != null
                                ? Text('${whitelistItem.comment}')
                                : null,
                            trailing: Icon(
                              KIcons.connectionStatus,
                              size: 8.0,
                              color: whitelistItem.isEnabled
                                  ? KColors.success
                                  : KColors.blocked,
                            ),
                            onTap: () {
                              final x = whitelistItem.domain
                                  .startsWith(wildcardPrefix);
                              print(
                                  '${whitelistItem.domain}.startsWith(`$wildcardPrefix`) = $x');
                              print(whitelistItem.isWildcard);
                            },
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

class _AddToWhitelistButton extends StatefulWidget {
  const _AddToWhitelistButton({
    Key key,
  }) : super(key: key);

  @override
  __AddToWhitelistButtonState createState() => __AddToWhitelistButtonState();
}

class __AddToWhitelistButtonState extends State<_AddToWhitelistButton> {
  TextEditingController _searchEditingController;
  PersistentBottomSheetController _persistentBottomSheetController;
  bool isWildcard = false;

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
        tooltip: 'Add to whitelist',
        icon: Icon(KIcons.add),
        onPressed: () {
          setState(() {
            notifier.startSearching();
            isWildcard = false;
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
                                      BlocProvider.of<ListBloc>(context).add(
                                          ListBlocEvent.addToWhitelist(
                                              isWildcard
                                                  ? '$wildcardPrefix$value$wildcardSuffix'
                                                  : value,
                                              isWildcard));
                                      Navigator.pop(context);
                                    },
                                    decoration: InputDecoration(
                                      prefixText:
                                          isWildcard ? wildcardPrefix : null,
                                      suffixText:
                                          isWildcard ? wildcardSuffix : null,
                                      border: InputBorder.none,
                                      hintText: 'Add to whitelist',
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
                                      value: isWildcard,
                                      onChanged: (bool value) {
                                        setState(() {
                                          isWildcard = value;
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

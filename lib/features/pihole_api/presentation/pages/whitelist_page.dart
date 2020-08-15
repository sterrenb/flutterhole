import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/pihole_api/blocs/list_bloc.dart';
import 'package:flutterhole/features/pihole_api/data/models/whitelist_item.dart';
import 'package:flutterhole/features/pihole_api/presentation/widgets/list_page_overflow_refresher.dart';
import 'package:flutterhole/features/routing/presentation/pages/page_scaffold.dart';
import 'package:flutterhole/features/routing/presentation/widgets/default_drawer.dart';
import 'package:flutterhole/widgets/layout/indicators/failure_indicators.dart';
import 'package:flutterhole/widgets/layout/indicators/loading_indicators.dart';

class WhitelistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      drawer: DefaultDrawer(),
      appBar: AppBar(
        title: Text('Whitelist'),
        elevation: 0.0,
      ),
      body: Builder(
        builder: (BuildContext context) => Scrollbar(
          child: ListPageOverflowRefresher(
            child:
                BlocBuilder<ListBloc, ListBlocState>(builder: (context, state) {
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
                            BlocProvider.of<ListBloc>(context)
                                .add(ListBlocEvent.removeFromWhitelist(
                              whitelistItem.domain,
                              whitelistItem.isWildcard,
                            ));
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
                          final x =
                              whitelistItem.domain.startsWith(wildcardPrefix);
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
    );
  }
}

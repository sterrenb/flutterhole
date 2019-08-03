import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/versions.dart';
import 'package:flutterhole/bloc/pihole/bloc.dart';
import 'package:flutterhole/model/pihole.dart';
import 'package:flutterhole/service/globals.dart';
import 'package:flutterhole/service/routes.dart';
import 'package:flutterhole/widget/layout/dismissible_background.dart';
import 'package:flutterhole/widget/layout/error_message.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:flutterhole/widget/pihole/pihole_button_row.dart';
import 'package:persist_theme/data/models/theme_model.dart';
import 'package:provider/provider.dart';

class PiholeListBuilder extends StatefulWidget {
  final bool editable;

  const PiholeListBuilder({Key key, this.editable = true}) : super(key: key);

  @override
  _PiholeListBuilderState createState() => _PiholeListBuilderState();
}

class _PiholeListBuilderState extends State<PiholeListBuilder> {
  List<Pihole> _cacheAll = [];
  Pihole _cacheActive;

  void _edit(BuildContext context, Pihole pihole) async {
    BlocProvider.of<VersionsBloc>(context).dispatch(FetchForPihole(pihole));
    final String message = await Globals.navigateTo(
      context,
      piholeEditPath(pihole),
    );
    if (message != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future _activate(Pihole pihole, BuildContext context) async {
    BlocProvider.of<PiholeBloc>(context).dispatch(ActivatePihole(pihole));
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Changing to ${pihole.title}')));
  }

  @override
  Widget build(BuildContext context) {
    final piholeBloc = BlocProvider.of<PiholeBloc>(context);
    return BlocListener(
      bloc: piholeBloc,
      listener: (context, state) {
        if (state is PiholeStateSuccess) {
          setState(() {
            _cacheAll = state.all;
            _cacheActive = state.active;
          });
        }
      },
      child: BlocBuilder(
        bloc: piholeBloc,
        builder: (context, state) {
          if (state is PiholeStateSuccess &&
              (_cacheAll == null || _cacheActive == null)) {
            // TODO obtain initial state, not during build
            _cacheAll = state.all;
            _cacheActive = state.active;
          }
          if (state is PiholeStateSuccess ||
              state is PiholeStateLoading && _cacheAll.isNotEmpty) {
            List<Widget> items = [];

            _cacheAll.forEach((pihole) {
              Widget tile;
              final bool isActive = (pihole == _cacheActive);
              if (widget.editable && _cacheAll.length > 1) {
                tile = Dismissible(
                  key: Key(pihole.title),
                  onDismissed: (direction) async {
                    final List<Pihole> original = _cacheAll;
                    setState(() {
                      _cacheAll.remove(pihole);
                    });
                    piholeBloc.dispatch(RemovePihole(pihole));
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Removing ${pihole.title}'),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            setState(() {
                              _cacheAll = original;
                            });
                            piholeBloc.dispatch(AddPihole(pihole));
                          }),
                    ));
                  },
                  background: DismissibleBackground(),
                  secondaryBackground:
                  DismissibleBackground(alignment: Alignment.centerRight),
                  child: PiholeTile(
                    pihole: pihole,
                    isActive: isActive,
                    onTap: () => _edit(context, pihole),
                    onLongPress: () => _activate(pihole, context),
                  ),
                );
              } else {
                tile = PiholeTile(
                  pihole: pihole,
                  isActive: isActive,
                  onTap: () async {
                    await _activate(pihole, context);
                    Navigator.of(context).pop();
                  },
                  onLongPress: () => _edit(context, pihole),
                );
              }

              items.add(tile);
            });

            if (items.isEmpty)
              items.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No configurations found.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption,
                ),
              ));

            return Column(
              children: <Widget>[
                widget.editable ? Container() : ListTab('Select configuration'),
                widget.editable ? Container() : Divider(),
                ...items,
                Divider(),
                widget.editable ? PiholeButtonRow() : Container(),
              ],
            );
          }

          if (state is PiholeStateError) {
            return ErrorMessage(errorMessage: state.e.toString());
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PiholeTile extends StatelessWidget {
  final Pihole pihole;
  final bool isActive;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const PiholeTile({Key key,
    @required this.pihole,
    this.isActive = false,
    this.onTap,
    this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);

    return ListTile(
      title: Text(pihole.title),
      subtitle: Text(pihole.baseUrl),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: isActive
          ? Icon(Icons.check, color: _theme.accentColor)
          : Icon(
        Icons.remove,
        color: Colors.black.withOpacity(0.0),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

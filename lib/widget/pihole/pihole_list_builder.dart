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
  List<Pihole> _all;
  Pihole _active;

  void _onTap(Pihole pihole) async {
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
    return BlocBuilder(
      bloc: piholeBloc,
      builder: (context, state) {
        if (state is PiholeStateSuccess) {
          _all = state.all;
          _active = state.active;

          List<Widget> items = [];

          if (_all != null) {
            _all.forEach((pihole) {
              Widget tile;
              final bool isActive = (pihole.title == _active.title);
              if (widget.editable) {
                tile = Dismissible(
                  key: Key(pihole.title),
                  onDismissed: (direction) async {
                    setState(() {
                      _all.remove(pihole);
                    });
                    piholeBloc.dispatch(RemovePihole(pihole));
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Removing ${pihole.title}'),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () async {
                            piholeBloc.dispatch(AddPihole(pihole));
                          }),
                    ));
                  },
                  background: DismissibleBackground(),
                  secondaryBackground:
                  DismissibleBackground(alignment: Alignment.centerRight),
                  child: PiholeTile(
                    pihole: pihole,
                    active: isActive,
                    onTap: () => _onTap(pihole),
                    onLongPress: () => _activate(pihole, context),
                  ),
                );
              } else {
                tile = PiholeTile(
                  pihole: pihole,
                  active: isActive,
                  onTap: () async {
                    await _activate(pihole, context);
                    Navigator.of(context).pop();
                  },
                );
              }

              items.add(tile);
            });
          }

          return Column(
            children: <Widget>[
              widget.editable ? Container() : ListTab('Select configuration'),
              widget.editable ? Container() : Divider(),
              ...items,
              Divider(),
              widget.editable
                  ? PiholeButtonRow(
                onStateChange: () {
                  setState(() {});
                },
              )
                  : Container(),
            ],
          );
        }

        if (state is PiholeStateError) {
          return Column(
            children: <Widget>[
              ErrorMessage(errorMessage: state.e.toString()),
              PiholeButtonRow(
                onStateChange: () {
                  setState(() {});
                },
              )
            ],
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class PiholeTile extends StatelessWidget {
  final Pihole pihole;
  final bool active;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const PiholeTile(
      {Key key,
      @required this.pihole,
        this.active = false,
        this.onTap,
        this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Provider.of<ThemeModel>(context);

    return ListTile(
      title: Text(pihole.title),
      subtitle: Text(pihole.basePath),
      trailing: Icon(Icons.keyboard_arrow_right),
      leading: Icon(Icons.check,
          color: active ? _theme.accentColor : Colors.black.withOpacity(0.0)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

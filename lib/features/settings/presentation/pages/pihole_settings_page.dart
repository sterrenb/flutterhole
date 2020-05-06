import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/blocs/pihole_settings_bloc.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PiholeSettingsPage extends StatelessWidget {
  const PiholeSettingsPage({
    Key key,
    @required this.initialValue,
  }) : super(key: key);

  final PiholeSettings initialValue;

  void _showJsonViewer(BuildContext context, PiholeSettings settings) {
    final Map<String, dynamic> json = settings.toJson();

    showMaterialModalBottomSheet(
      context: context,
      builder: (BuildContext context, ScrollController scrollController) {
        return Material(
          child: SafeArea(
              child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: json.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                title: Text('${json.values.elementAt(index)}'),
                subtitle: Text('${json.keys.elementAt(index)}'),
              );
            },
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PiholeSettingsBloc>(
      create: (_) =>
          PiholeSettingsBloc()..add(PiholeSettingsEvent.init(initialValue)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${initialValue.title}'),
        ),
        body: ListView(
          children: <Widget>[
            RaisedButton.icon(
              onPressed: () {
                _showJsonViewer(context, initialValue);
              },
              label: Text('JSON view'),
              icon: Icon(KIcons.pihole),
            ),
          ],
        ),
      ),
    );
  }
}

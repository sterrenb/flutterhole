import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/widget/blacklist/blacklist_item_form.dart';

class BlacklistAddForm extends StatefulWidget {
  @override
  _BlacklistAddFormState createState() => _BlacklistAddFormState();
}

class _BlacklistAddFormState extends State<BlacklistAddForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String get _entry => _fbKey.currentState.value[entryAttribute];

  String get _listType => _fbKey.currentState.value[listTypeAttribute];

  BlacklistItem get _item {
    final BlacklistType blacklistType = blacklistTypeFromString(_listType);
    String entry = _entry;

    if (blacklistType == BlacklistType.Wildcard) {
      if (!entry.startsWith(wildcardPrefix)) {
        entry = wildcardPrefix + entry;
      }

      if (!entry.endsWith(wildcardSuffix)) {
        entry = entry + wildcardSuffix;
      }
    }

    return BlacklistItem(
      entry: entry,
      type: blacklistType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocListener(
      bloc: blacklistBloc,
      listener: (context, state) {
        if (state is BlocStateSuccess<Blacklist>) {
          Navigator.of(context).pop(_item);
        }
      },
      child: BlacklistItemForm(
        fbKey: _fbKey,
        onSubmit: () {
          _fbKey.currentState.save();
          blacklistBloc.dispatch(Add(_item));
        },
      ),
    );
  }
}

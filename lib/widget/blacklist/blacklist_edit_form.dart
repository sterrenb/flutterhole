import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole_again/bloc/blacklist/bloc.dart';
import 'package:flutterhole_again/model/blacklist.dart';
import 'package:flutterhole_again/widget/blacklist/blacklist_form.dart';

class BlacklistEditForm extends StatefulWidget {
  final BlacklistItem original;

  const BlacklistEditForm({Key key, @required this.original}) : super(key: key);

  @override
  _BlacklistEditFormState createState() => _BlacklistEditFormState();
}

class _BlacklistEditFormState extends State<BlacklistEditForm> {
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
        if (state is BlacklistStateSuccess) {
          if (_entry == null) {
            Navigator.of(context).pop('Removed ${widget.original.entry}');
          } else {
            Navigator.of(context)
                .pop('Edited ${widget.original.entry} to ${_item.entry}');
          }
        }
      },
      child: BlacklistForm(
        fbKey: _fbKey,
        initialValue: widget.original,
        onVoidSubmitted: () {
          _fbKey.currentState.save();
          if (widget.original != _item) {
            blacklistBloc.dispatch(EditOnBlacklist(widget.original, _item));
          }
        },
      ),
    );
  }
}

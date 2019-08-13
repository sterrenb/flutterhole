import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/widget/whitelist/whitelist_form.dart';

class WhitelistEditForm extends StatefulWidget {
  final String original;

  const WhitelistEditForm({Key key, @required this.original}) : super(key: key);

  @override
  _WhitelistEditFormState createState() => _WhitelistEditFormState();
}

class _WhitelistEditFormState extends State<WhitelistEditForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String get _update => _fbKey.currentState.value[domainAttribute];

  @override
  Widget build(BuildContext context) {
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    return BlocListener(
      bloc: whitelistBloc,
      listener: _listener,
      child: _buildWhitelistForm(whitelistBloc),
    );
  }

  WhitelistForm _buildWhitelistForm(WhitelistBloc whitelistBloc) {
    return WhitelistForm(
      fbKey: _fbKey,
      initialValue: widget.original,
      onSubmit: () {
        _fbKey.currentState.save();
        if (widget.original != _update) {
          whitelistBloc.dispatch(Edit(widget.original, _update));
        }
      },
    );
  }

  void _listener(context, state) {
    if (state is BlocStateSuccess<Whitelist>) {
      if (_update == null) {
        Navigator.of(context).pop('Removed ${widget.original}');
      } else {
        Navigator.of(context).pop('Edited ${widget.original} to $_update');
      }
    }
  }
}

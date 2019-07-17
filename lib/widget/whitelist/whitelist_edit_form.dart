import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole_again/bloc/whitelist/bloc.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_form.dart';

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
      listener: (context, state) {
        if (state is WhitelistStateSuccess) {
          if (_update == null) {
            Navigator.of(context).pop('Removed ${widget.original}');
          } else {
            Navigator.of(context).pop('Edited ${widget.original} to $_update');
          }
        }
      },
      child: WhitelistForm(
        fbKey: _fbKey,
        initialValue: widget.original,
        onVoidSubmitted: () {
          _fbKey.currentState.save();
          if (widget.original != _update) {
            whitelistBloc.dispatch(
                EditOnWhitelist(original: widget.original, update: _update));
          }
        },
      ),
    );
  }
}

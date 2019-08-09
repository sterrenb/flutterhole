import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/widget/blacklist/blacklist_item_form.dart';

class BlacklistAddForm extends StatefulWidget {
  @override
  _BlacklistAddFormState createState() => _BlacklistAddFormState();
}

class _BlacklistAddFormState extends State<BlacklistAddForm>
    with BlacklistFormParent {
  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocListener(
      bloc: blacklistBloc,
      listener: _listener,
      child: _buildBlacklistItemForm(blacklistBloc),
    );
  }

  BlacklistItemForm _buildBlacklistItemForm(BlacklistBloc blacklistBloc) {
    return BlacklistItemForm(
      fbKey: formBuilderKey,
      onSubmit: () {
        formBuilderKey.currentState.save();
        blacklistBloc.dispatch(Add(localItem));
      },
    );
  }

  void _listener(context, state) {
    if (state is BlocStateSuccess<Blacklist>) {
      Navigator.of(context).pop(localItem);
    }
  }
}

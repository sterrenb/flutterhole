import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/widget/blacklist/blacklist_item_form.dart';

class BlacklistEditForm extends StatefulWidget {
  final BlacklistItem original;

  const BlacklistEditForm({Key key, @required this.original}) : super(key: key);

  @override
  _BlacklistEditFormState createState() => _BlacklistEditFormState();
}

class _BlacklistEditFormState extends State<BlacklistEditForm>
    with BlacklistFormParent {
  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);
    return BlocListener(
      bloc: blacklistBloc,
      listener: (context, state) {
        if (state is BlocStateSuccess<Blacklist>) {
          if (localEntry == null) {
            Navigator.of(context).pop('Removed ${widget.original.entry}');
          } else {
            Navigator.of(context)
                .pop('Edited ${widget.original.entry} to ${localItem.entry}');
          }
        }
      },
      child: BlacklistItemForm(
        fbKey: formBuilderKey,
        initialValue: widget.original,
        onSubmit: () {
          formBuilderKey.currentState.save();
          if (widget.original != localItem) {
            blacklistBloc.dispatch(Edit(widget.original, localItem));
          }
        },
      ),
    );
  }
}

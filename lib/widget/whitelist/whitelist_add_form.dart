import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/widget/whitelist/whitelist_form.dart';

class WhitelistAddForm extends StatefulWidget {
  @override
  _WhitelistAddFormState createState() => _WhitelistAddFormState();
}

class _WhitelistAddFormState extends State<WhitelistAddForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String get _domain => _fbKey.currentState.value[domainAttribute];

  @override
  Widget build(BuildContext context) {
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    return BlocListener(
      bloc: whitelistBloc,
      listener: (context, state) {
        if (state is BlocStateSuccess<Whitelist>) {
          Navigator.of(context).pop(_domain);
        }
      },
      child: WhitelistForm(
        fbKey: _fbKey,
        onVoidSubmitted: () {
          _fbKey.currentState.save();
          whitelistBloc.dispatch(Add(_domain));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_event.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_state.dart';
import 'package:flutterhole_again/widget/whitelist/whitelist_form.dart';

class WhitelistAddForm extends StatefulWidget {
  @override
  _WhitelistAddFormState createState() => _WhitelistAddFormState();
}

class _WhitelistAddFormState extends State<WhitelistAddForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  String get _domain => _fbKey.currentState.value[domainAttribute];

  bool submitting;

  @override
  void initState() {
    super.initState();
    submitting = false;
  }

  @override
  Widget build(BuildContext context) {
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);
    return BlocListener(
      bloc: whitelistBloc,
      listener: (context, state) {
        if (submitting && state is WhitelistStateSuccess) {
          Navigator.of(context).pop(_domain);
        }
      },
      child: WhitelistForm(
        fbKey: _fbKey,
        onVoidSubmitted: () {
          _fbKey.currentState.save();
          setState(() {
            submitting = true;
          });
          whitelistBloc.dispatch(
              AddToWhitelist(_domain));
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_bloc.dart';
import 'package:flutterhole_again/bloc/whitelist/whitelist_state.dart';

const domainAttribute = "domain";

class WhitelistForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final VoidCallback onVoidSubmitted;

  final String initialValue;

  WhitelistForm({
    Key key,
    @required this.fbKey,
    @required this.onVoidSubmitted,
    this.initialValue = '',
  }) : super(key: key);

  @override
  _WhitelistFormState createState() => _WhitelistFormState();
}

class _WhitelistFormState extends State<WhitelistForm> {
  @override
  Widget build(BuildContext context) {
    final WhitelistBloc whitelistBloc = BlocProvider.of<WhitelistBloc>(context);

    return BlocListener(
      bloc: whitelistBloc,
      listener: (context, state) {
        if (state is WhitelistStateError) {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Text(state.errorMessage)
          ])));
        }
      },
      child: Column(
        children: <Widget>[
          FormBuilder(
              key: widget.fbKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: domainAttribute,
                    decoration: InputDecoration(labelText: "Domain"),
                    autofocus: true,
                    initialValue: widget.initialValue,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.url,
                    // submission with Enter key doesn't work, see https://github.com/flutter/flutter/issues/19027
                    onFieldSubmitted: (_) {
                      if (widget.fbKey.currentState.validate()) {
                        widget.onVoidSubmitted();
                      }
                    },
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.url(),
                    ],
                  ),
                ],
              )),
          Row(
            children: <Widget>[
              MaterialButton(
                child: Text("Submit"),
                onPressed: () {
                  if (widget.fbKey.currentState.validate()) {
                    widget.onVoidSubmitted();
                  }
                },
              ),
              MaterialButton(
                child: Text("Reset"),
                onPressed: () {
                  widget.fbKey.currentState.reset();
                },
              ),
              BlocBuilder(
                bloc: whitelistBloc,
                builder: (context, state) {
                  if (state is WhitelistStateLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Container();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

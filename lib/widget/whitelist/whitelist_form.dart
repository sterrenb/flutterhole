import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/whitelist.dart';
import 'package:flutterhole/bloc/base/bloc.dart';
import 'package:flutterhole/model/api/whitelist.dart';
import 'package:flutterhole/widget/layout/dialog.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';

const domainAttribute = "domain";

class WhitelistForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final VoidCallback onSubmit;

  final String initialValue;

  WhitelistForm({
    Key key,
    @required this.fbKey,
    @required this.onSubmit,
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
      listener: _listener,
      child: Column(
        children: <Widget>[_buildFormBuilder(), _buildButtonRow(whitelistBloc)],
      ),
    );
  }

  Widget _buildButtonRow(WhitelistBloc whitelistBloc) {
    return Row(
      children: <Widget>[
        MaterialButton(
          child: Text("Submit"),
          onPressed: () {
            if (widget.fbKey.currentState.validate()) {
              widget.onSubmit();
            }
          },
        ),
        MaterialButton(
          child: Text("Reset"),
          onPressed: () {
            widget.fbKey.currentState.reset();
          },
        ),
        widget.initialValue.isNotEmpty
            ? IconTextButton(
          title: 'Remove',
          icon: Icons.delete_outline,
          color: Colors.red,
          onPressed: () {
            _showRemoveDialog(whitelistBloc);
          },
        )
            : Container(),
        BlocBuilder(
          bloc: whitelistBloc,
          builder: (context, state) {
            if (state is BlocStateLoading<Whitelist>) {
              return Center(child: CircularProgressIndicator());
            }

            return Container();
          },
        ),
      ],
    );
  }

  void _showRemoveDialog(WhitelistBloc whitelistBloc) {
    showAlertDialog(
        context,
        Container(
          child: Text("Do you want to remove ${widget.initialValue}?"),
        ), onConfirm: () {
      whitelistBloc.dispatch(Remove(widget.initialValue));
    });
  }

  FormBuilder _buildFormBuilder() {
    return FormBuilder(
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
              // submission with Enter key doesn't work in emulators, see https://github.com/flutter/flutter/issues/19027
              onFieldSubmitted: (_) {
                if (widget.fbKey.currentState.validate()) {
                  widget.onSubmit();
                }
              },
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.url(),
              ],
            ),
          ],
        ));
  }

  void _listener(context, state) {
    if (state is BlocStateSuccess<Whitelist>) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('${widget.initialValue} removed')));
    }
    if (state is BlocStateError<Whitelist>) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Text(state.e.message)
          ])));
    }
  }
}

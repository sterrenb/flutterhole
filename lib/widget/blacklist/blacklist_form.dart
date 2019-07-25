import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/blacklist/bloc.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/blacklist.dart';
import 'package:flutterhole/widget/layout/dialog.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';

const entryAttribute = "entry";
const listTypeAttribute = "listType";

class BlacklistForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final VoidCallback onVoidSubmitted;

  final BlacklistItem initialValue;

  BlacklistForm({
    Key key,
    @required this.fbKey,
    @required this.onVoidSubmitted,
    this.initialValue,
  }) : super(key: key);

  @override
  _BlacklistFormState createState() => _BlacklistFormState();
}

class _BlacklistFormState extends State<BlacklistForm> {
  BlacklistType selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialValue == null
        ? BlacklistType.Exact
        : widget.initialValue.type;
  }

  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);

    return BlocListener(
      bloc: blacklistBloc,
      listener: (context, state) {
        if (state is BlocStateSuccess<Blacklist>) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('${widget.initialValue} removed')));
        }
        if (state is BlocStateError<Blacklist>) {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Row(children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Text(state.e.message)
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
                    attribute: entryAttribute,
                    decoration: InputDecoration(
                        labelText: "Blacklist entry",
                        prefixText: selectedType == BlacklistType.Wildcard
                            ? wildcardPrefix
                            : '',
                        suffixText: selectedType == BlacklistType.Wildcard
                            ? wildcardSuffix
                            : ''),
                    autofocus: true,
                    initialValue: (widget.initialValue != null)
                        ? widget.initialValue.entry
                            .replaceFirst(wildcardPrefix, '')
                            .replaceFirst(wildcardSuffix, '')
                        : '',
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.text,
                    onFieldSubmitted: (_) {
                      if (widget.fbKey.currentState.validate()) {
                        widget.onVoidSubmitted();
                      }
                    },
                    validators: [FormBuilderValidators.required()],
                  ),
                  FormBuilderRadio(
                    attribute: listTypeAttribute,
                    decoration: InputDecoration(labelText: 'List type'),
                    initialValue: (widget.initialValue != null)
                        ? widget.initialValue.type
                            .toString()
                            .replaceAll('BlacklistType.', '')
                        : "Exact",
                    onChanged: (val) {
                      print('onchanged $val');
                      setState(() {
                        selectedType = blacklistTypeFromString(val);
                      });
                    },
                    leadingInput: true,
                    validators: [FormBuilderValidators.required()],
                    options: [
                      "Exact",
                      "Wildcard",
                      "Regex",
                    ]
                        .map((lang) => FormBuilderFieldOption(value: lang))
                        .toList(growable: false),
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
              widget.initialValue != null
                  ? IconTextButton(
                      title: 'Remove',
                      icon: Icons.delete_outline,
                      color: Colors.red,
                      onPressed: () {
                        showAlertDialog(
                            context,
                            Container(
                              child: Text(
                                  "Do you want to remove ${widget.initialValue.entry}?"),
                            ),
                            continueText: 'Remove', onConfirm: () {
                          blacklistBloc.dispatch(Remove(widget.initialValue));
                        });
                      },
                    )
                  : Container(),
              BlocBuilder(
                bloc: blacklistBloc,
                builder: (context, state) {
                  if (state is BlocStateLoading<Blacklist>) {
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

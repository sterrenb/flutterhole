import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/bloc/api/blacklist.dart';
import 'package:flutterhole/bloc/base/state.dart';
import 'package:flutterhole/model/api/blacklist.dart';
import 'package:flutterhole/widget/layout/dialog.dart';
import 'package:flutterhole/widget/layout/icon_text_button.dart';

const entryAttribute = "entry";
const listTypeAttribute = "listType";

class BlacklistItemForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> fbKey;
  final VoidCallback onSubmit;

  final BlacklistItem initialValue;

  BlacklistItemForm({
    Key key,
    @required this.fbKey,
    @required this.onSubmit,
    this.initialValue,
  }) : super(key: key);

  @override
  _BlacklistItemFormState createState() => _BlacklistItemFormState();
}

class _BlacklistItemFormState extends State<BlacklistItemForm> {
  BlacklistType selectedType;

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialValue?.type ?? BlacklistType.Exact;
  }

  @override
  Widget build(BuildContext context) {
    final BlacklistBloc blacklistBloc = BlocProvider.of<BlacklistBloc>(context);

    return BlocListener(
      bloc: blacklistBloc,
      listener: _listener,
      child: Column(
        children: <Widget>[
          _buildFormBuilder(),
          _buildButtonRow(blacklistBloc),
        ],
      ),
    );
  }

  Widget _buildFormBuilder() {
    return FormBuilder(
        key: widget.fbKey,
        autovalidate: true,
        child: Column(
          children: <Widget>[
            _buildEntryTextField(),
            _buildListTypeRadio(),
          ],
        ));
  }

  FormBuilderTextField _buildEntryTextField() {
    return FormBuilderTextField(
      attribute: entryAttribute,
      decoration: InputDecoration(
          labelText: "Blacklist entry",
          prefixText:
          (selectedType == BlacklistType.Wildcard) ? wildcardPrefix : '',
          suffixText:
          (selectedType == BlacklistType.Wildcard) ? wildcardSuffix : ''),
      autofocus: true,
      initialValue: widget.initialValue?.entry
          ?.replaceFirst(wildcardPrefix, '')
          ?.replaceFirst(wildcardSuffix, '') ??
          '',
      onFieldSubmitted: (_) {
        _submit();
      },
      validators: [FormBuilderValidators.required()],
    );
  }

  Widget _buildListTypeRadio() {
    return FormBuilderRadio(
      attribute: listTypeAttribute,
      decoration: InputDecoration(labelText: 'List type'),
      initialValue: blacklistTypeToString(
          widget.initialValue?.type ?? BlacklistType.Exact),
      onChanged: (val) {
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
      ].map((lang) => FormBuilderFieldOption(value: lang)).toList(),
    );
  }

  Row _buildButtonRow(BlacklistBloc blacklistBloc) {
    return Row(
      children: <Widget>[
        MaterialButton(
          child: Text("Submit"),
          onPressed: () {
            _submit();
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
                ), onConfirm: () {
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
    );
  }

  void _submit() {
    if (widget.fbKey.currentState.validate()) {
      widget.onSubmit();
    }
  }

  void _listener(context, state) {
    if (state is BlocStateSuccess<Blacklist>) {
      _showSnackBarSuccess();
    }
    if (state is BlocStateError<Blacklist>) {
      _showErrorSnackBar(state);
    }
  }

  void _showSnackBarSuccess() {
    Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('${widget.initialValue} removed')));
  }

  void _showErrorSnackBar(BlocStateError<Blacklist> state) {
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

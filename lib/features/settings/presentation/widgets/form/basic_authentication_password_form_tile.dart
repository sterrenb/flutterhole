import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class BasicAuthenticationPasswordFormTile extends StatefulWidget {
  const BasicAuthenticationPasswordFormTile({
    Key key,
    @required this.initialValue,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final PiholeSettings initialValue;
  final InputDecoration decoration;

  @override
  _BasicAuthenticationPasswordFormTileState createState() =>
      _BasicAuthenticationPasswordFormTileState();
}

class _BasicAuthenticationPasswordFormTileState
    extends State<BasicAuthenticationPasswordFormTile> {
  TextEditingController _passwordController;
  bool _passwordVisible;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(
        text: widget.initialValue.basicAuthenticationPassword);
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'basicAuthenticationPassword',
        controller: _passwordController,
        decoration: widget.decoration.copyWith(
          labelText: 'BasicAuth Password',
          suffixIcon: IconButton(
            tooltip: 'Toggle visibility',
            icon: Icon(
              _passwordVisible ? KIcons.visibility_on : KIcons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
        autocorrect: false,
        maxLines: 1,
        obscureText: !_passwordVisible,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class BaseUrlFormTile extends StatelessWidget {
  const BaseUrlFormTile({
    Key key,
    @required this.initialValue,
     this.decoration = const InputDecoration(),
  }) : super(key: key);

  final PiholeSettings initialValue;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Flexible(
            flex: 3,
            child: FormBuilderTextField(
              attribute: 'baseUrl',
              decoration: decoration.copyWith(
                labelText: 'Base URL',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 8.0),
          Flexible(
            flex: 1,
            child: FormBuilderTextField(
              attribute: 'apiPort',
              initialValue: initialValue.apiPort.toString(),
              decoration: decoration.copyWith(
                labelText: 'Port',
              ),
              maxLines: 1,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(0),
                FormBuilderValidators.max(65535),
              ],
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly,
              ],
              valueTransformer: (value) => int.tryParse(value ?? 80),
            ),
          ),
        ],
      ),
    );
  }
}

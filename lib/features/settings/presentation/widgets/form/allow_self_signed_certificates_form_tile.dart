import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AllowSelfSignedCertificatesFormTile extends StatelessWidget {
  const AllowSelfSignedCertificatesFormTile({
    Key key,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderCheckbox(
        attribute: 'allowSelfSignedCertificates',
        decoration: decoration.copyWith(
          helperText:
              'Trust all certificates, even when the TLS handshake fails. \nUseful for using HTTPs over your own certificate.',
        ),
        label: Text('Allow self-signed certificates'),
      ),
    );
  }
}

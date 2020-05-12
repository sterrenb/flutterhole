import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DescriptionFormTile extends StatelessWidget {
  const DescriptionFormTile({
    Key key,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'description',
        decoration: decoration.copyWith(labelText: 'Description (optional)'),
        textCapitalization: TextCapitalization.sentences,
        minLines: 1,
        maxLines: 5,
      ),
    );
  }
}

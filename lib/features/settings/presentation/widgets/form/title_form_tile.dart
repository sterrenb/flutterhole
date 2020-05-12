import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class TitleFormTile extends StatelessWidget {
  const TitleFormTile({
    Key key,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderTextField(
        attribute: 'title',
        decoration: decoration.copyWith(labelText: 'Title'),
        autocorrect: false,
        textCapitalization: TextCapitalization.words,
        maxLines: 1,
        validators: [
          FormBuilderValidators.required(),
        ],
      ),
    );
  }
}

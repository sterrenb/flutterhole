import 'package:flutter/material.dart';

class OptionDialogItem<T> extends StatelessWidget {
  const OptionDialogItem({
    Key? key,
    required this.option,
    required this.title,
  }) : super(key: key);

  final T option;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: () => Navigator.of(context).pop(option),
      title: Text('$title'),
    );
  }
}

Future<T?> showOptionDialog<T>({
  required BuildContext context,
  required Widget title,
  required List<OptionDialogItem<T>> options,
  bool barrierDismissible = true,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SimpleDialog(
      title: title,
      children: options,
    ),
  );
}

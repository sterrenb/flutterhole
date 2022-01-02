import 'package:flutter/material.dart';

typedef DropDownItemBuilder<T> = Widget Function(BuildContext context, T value);

class IconDropDownButtonBuilder<T> extends StatelessWidget {
  const IconDropDownButtonBuilder({
    Key? key,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.builder,
    this.icons = const [],
  })  : assert(icons.length == 0 || values.length == icons.length),
        super(key: key);
  final T value;
  final List<T> values;
  final List<IconData> icons;
  final ValueChanged<T> onChanged;
  final DropDownItemBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return DropDownButtonBuilder<T>(
      value: value,
      onChanged: onChanged,
      values: values,
      builder: (context, element) {
        return Row(
          children: [
            if (icons.isNotEmpty)
              Icon(icons.elementAt(values.indexOf(element))),
            const SizedBox(width: 8.0),
            builder(context, element),
          ],
        );
      },
    );
  }
}

class DropDownButtonBuilder<T> extends StatelessWidget {
  const DropDownButtonBuilder({
    Key? key,
    required this.value,
    required this.values,
    required this.onChanged,
    required this.builder,
  }) : super(key: key);

  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;
  final DropDownItemBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      onChanged: (update) {
        if (update != null) {
          return onChanged(update);
        }
      },
      items: values
          .map<DropdownMenuItem<T>>((e) => DropdownMenuItem(
                value: e,
                child: builder(context, e),
              ))
          .toList(),
    );
  }
}

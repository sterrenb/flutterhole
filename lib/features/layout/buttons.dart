import 'package:flutter/material.dart';
import 'package:flutterhole_web/constants.dart';

class TryAgainButton extends StatelessWidget {
  const TryAgainButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(KIcons.refresh),
      label: const Text('Try again'),
    );
  }
}

typedef DropDownItemBuilder<T> = Widget Function(BuildContext context, T value);

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

class IconDropDownButtonBuilder<T> extends StatelessWidget {
  const IconDropDownButtonBuilder({
    Key? key,
    required this.value,
    required this.values,
    required this.icons,
    required this.onChanged,
    required this.builder,
  })  : assert(values.length == icons.length),
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
            Icon(icons.elementAt(values.indexOf(element))),
            const SizedBox(width: 8.0),
            builder(context, element),
          ],
        );
      },
    );
  }
}

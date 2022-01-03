import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterhole/intl/formatting.dart';
import 'package:flutterhole/widgets/layout/grids.dart';

class TileTextField extends HookWidget {
  const TileTextField({
    Key? key,
    required this.controller,
    required this.inputFormatters,
    required this.keyboardType,
    required this.hintText,
    this.enabled = true,
    this.style,
    this.decoration,
    this.textAlign,
    this.textCapitalization,
    this.maxLines,
    this.obscureText = false,
    this.expands = true,
  }) : super(key: key);

  final bool enabled;
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final TextAlign? textAlign;
  final TextCapitalization? textCapitalization;
  final bool obscureText;
  final bool expands;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final node = useFocusNode(debugLabel: hintText);
    final _decoration = InputDecoration(
      hintText: hintText,
      // labelText: node.hasFocus ? hintText : null,
      // focusColor: Colors.orangeAccent,
      // border: const OutlineInputBorder(
      //     borderRadius: BorderRadius.all(Radius.circular(20))),
      // borderRadius: BorderRadius.all(Radius.circular(kGridSpacing))),
      // enabledBorder: OutlineInputBorder(
      //   borderSide: BorderSide(
      //     color: Theme.of(context).dividerColor,
      //     width: 1.0,
      //   ),
      // ),
    );

    return TextField(
      enabled: enabled,
      controller: controller,
      focusNode: node,
      expands: expands,
      maxLines: maxLines,
      textAlignVertical: TextAlignVertical.center,
      textAlign: textAlign ?? TextAlign.center,
      style: style,
      inputFormatters: [
        ...inputFormatters,
      ],
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      obscureText: obscureText,
      decoration: decoration != null
          ? decoration!.copyWith(
              hintText: _decoration.hintText,
              labelText: _decoration.labelText,
              border: _decoration.border,
              enabledBorder: _decoration.enabledBorder,
              // contentPadding: EdgeInsets.all(18.0),
            )
          : _decoration,
    );
  }
}

class GridSectionTitle extends StatelessWidget {
  const GridSectionTitle(
    this.title, {
    this.color,
    Key? key,
  }) : super(key: key);

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6,
      textAlign: TextAlign.left,
    );
  }
}

class GridSectionHeader extends StatelessWidget {
  const GridSectionHeader(
    this.title,
    this.iconData, {
    Key? key,
  }) : super(key: key);

  final String title;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kGridSpacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Icon(iconData),
              ),
              GridSectionTitle(title),
            ],
          ),
        ],
      ),
    );
  }
}

class TitleCard extends StatelessWidget {
  const TitleCard(
    this.titleController, {
    Key? key,
  }) : super(key: key);

  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TileTextField(
        controller: titleController,
        style: Theme.of(context).textTheme.headline4,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [
          LengthLimitingTextInputFormatter(30),
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        hintText: 'Title',
      ),
    );
  }
}

class BaseUrlCard extends StatelessWidget {
  const BaseUrlCard(
    this.baseUrlController, {
    Key? key,
    required this.useSsl,
  }) : super(key: key);

  final TextEditingController baseUrlController;
  final bool useSsl;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Base URL",
      child: Card(
        child: TileTextField(
          controller: baseUrlController,
          style: Theme.of(context).textTheme.headline6,
          keyboardType: TextInputType.url,
          textAlign: TextAlign.start,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
            FilteringTextInputFormatter.singleLineFormatter,
            Formatting.whitespaceFormatter,
          ],
          hintText: 'Base URL',
          decoration: InputDecoration(
            prefixText: useSsl ? 'https://' : 'http://',
          ),
        ),
      ),
    );
  }
}

class ApiPortCard extends StatelessWidget {
  const ApiPortCard(
    this.apiPortController, {
    Key? key,
  }) : super(key: key);

  final TextEditingController apiPortController;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Api port",
      child: Card(
        child: TileTextField(
          controller: apiPortController,
          style: Theme.of(context).textTheme.headline6,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(5),
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          hintText: 'API port',
        ),
      ),
    );
  }
}

class ApiPathCard extends StatelessWidget {
  const ApiPathCard(
    this.apiPathController, {
    Key? key,
  }) : super(key: key);

  final TextEditingController apiPathController;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "API path",
      child: Card(
        child: TileTextField(
          controller: apiPathController,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline6,
          keyboardType: TextInputType.url,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
            FilteringTextInputFormatter.singleLineFormatter,
            Formatting.whitespaceFormatter,
          ],
          hintText: 'API path',
        ),
      ),
    );
  }
}

class UseSslCard extends StatelessWidget {
  const UseSslCard({
    Key? key,
    required this.useSsl,
    required this.onChanged,
    required this.onTap,
  }) : super(key: key);

  final bool useSsl;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          const Text('Use SSL'),
          Checkbox(
            value: useSsl,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

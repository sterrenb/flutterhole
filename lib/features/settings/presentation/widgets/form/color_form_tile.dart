import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}

class PrimaryColorFormTile extends StatelessWidget {
  const PrimaryColorFormTile({
    Key key,
    @required this.initialValue,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final PiholeSettings initialValue;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderColorPicker(
        attribute: 'primaryColor',
        initialValue: initialValue.primaryColor,
        decoration: decoration.copyWith(labelText: 'Primary color'),
        valueTransformer: (value) => (value as Color).toHex(),
        colorPickerType: ColorPickerType.MaterialPicker,
      ),
    );
  }
}

class AccentColorFormTile extends StatelessWidget {
  const AccentColorFormTile({
    Key key,
    @required this.initialValue,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  final PiholeSettings initialValue;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: FormBuilderColorPicker(
        attribute: 'accentColor',
        initialValue: initialValue.accentColor,
        decoration: decoration.copyWith(labelText: 'Accent color'),
        valueTransformer: (value) => (value as Color).toHex(),
        colorPickerType: ColorPickerType.MaterialPicker,
      ),
    );
  }
}
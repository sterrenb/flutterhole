import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/features/layout/grid.dart';

class TileTextField extends StatelessWidget {
  const TileTextField({
    Key? key,
    required this.controller,
    required this.inputFormatters,
    required this.keyboardType,
    required this.hintText,
    this.style,
  }) : super(key: key);

  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String hintText;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      expands: true,
      maxLines: null,
      textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.center,
      style: style,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        focusColor: Colors.orangeAccent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(kGridSpacing)),
          borderSide: BorderSide(color: Colors.blue, width: 5.0),
        ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(kGridSpacing)),
        //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
        // ),
      ),
      // keyboardType: TextInputType.text,
      // minLines: 1,
      // maxLines: 1,
    );
  }
}

extension ColorX on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class PrimaryColorCard extends HookWidget {
  const PrimaryColorCard(
    this.primaryColor,
    this.onSelected, {
    Key? key,
  }) : super(key: key);

  final Color primaryColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: primaryColor,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kGridSpacing)),
        onTap: () async {
          final selectedColor = await showModal<Color?>(
            context: context,
            builder: (context) {
              return _Dialog(primaryColor);
            },
          );

          print(selectedColor);
          if (selectedColor != null) {
            onSelected(selectedColor);
          }
        },
        child: Center(
          child: Opacity(
            opacity: .5,
            child: Text(
              primaryColor.toHexTriplet(),
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dialog extends HookWidget {
  const _Dialog(
    this.primaryColor, {
    Key? key,
  }) : super(key: key);

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final selected = useState(primaryColor);
    final widthFreq = useState(Random().nextInt(5) + 4);
    return DialogBase(
      header: DialogHeader(title: "Primary color", message: "That it"),
      body: StaggeredGridView.countBuilder(
        shrinkWrap: true,
        crossAxisCount: 4,
        itemCount: Colors.accents.length,
        itemBuilder: (context, index) {
          final color = Colors.accents.elementAt(index);
          final lum = color.computeLuminance();
          final isPrimary = color.value == selected.value.value;
          final onBackground = lum > .5 ? Colors.black : Colors.white;
          return Card(
            color: color,
            child: InkWell(
              onTap: () {
                selected.value = color;
              },
              child: Opacity(
                opacity: .5 - lum / 4,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: kThemeChangeDuration,
                    switchInCurve: Curves.ease,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: isPrimary
                        ? Icon(
                            KIcons.selected,
                            color: onBackground,
                          )
                        : Text(
                            // isPrimary.toString(),
                            color.toHexTriplet(),
                            style: TextStyle(
                              color: onBackground,
                            ),
                          ),
                  ),
                ),
              ),
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kGridSpacing)),
            ),
          );
        },
        staggeredTileBuilder: (index) {
          final color = Colors.accents.elementAt(index);
          if (color.value == primaryColor.value) {
            return StaggeredTile.count(2, 2);
          }
          final wideBoi = index % widthFreq.value == 0;
          return StaggeredTile.count(wideBoi ? 2 : 1, 1);
        },
      ),
      onSelect: () {
        Navigator.of(context).pop(selected.value);
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
      theme: Theme.of(context),
    );
  }
}

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterhole_web/constants.dart';
import 'package:flutterhole_web/dialogs.dart';
import 'package:flutterhole_web/entities.dart';
import 'package:flutterhole_web/features/grid/grid_layout.dart';
import 'package:flutterhole_web/features/layout/code_card.dart';
import 'package:flutterhole_web/features/settings/single_pi_grid.dart';
import 'package:flutterhole_web/features/settings/themes.dart';
import 'package:flutterhole_web/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(kGridSpacing))),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1.0,
        ),
      ),
      // focusedBorder: OutlineInputBorder(
      //   borderRadius: BorderRadius.all(Radius.circular(kGridSpacing)),
      //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
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

class ColorCard extends StatelessWidget {
  const ColorCard({
    Key? key,
    required this.title,
    required this.currentColor,
    required this.colors,
    required this.onSelected,
  }) : super(key: key);

  final String title;
  final Color currentColor;
  final List<Color> colors;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridCard(
      color: currentColor,
      child: Tooltip(
        message: title,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kGridSpacing)),
          onTap: () async {
            final selectedColor = await showModalBottomSheet<Color?>(
              context: context,
              builder: (context) {
                return DraggableScrollableSheet(
                  initialChildSize: 1.0,
                  minChildSize: 0.95,
                  builder: (context, controller) {
                    return ColorGrid(
                      controller: controller,
                      colors: colors,
                      initial: currentColor,
                      onSelected: onSelected,
                      // header: Center(child: TileTitle(title)),
                    );
                  },
                );
              },
            );
            if (selectedColor != null) {
              onSelected(selectedColor);
            }
          },
          child: Center(
            child: Opacity(
              opacity: .5,
              child: Text(
                currentColor.toHexTriplet(),
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: currentColor.computeForegroundColor()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ColorGrid extends HookWidget {
  const ColorGrid({
    Key? key,
    required this.colors,
    required this.initial,
    required this.controller,
    required this.onSelected,
  }) : super(key: key);

  final List<Color> colors;
  final Color initial;
  final ScrollController controller;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = useState(initial);

    return StaggeredGridView.countBuilder(
      controller: controller,
      crossAxisCount: 4,
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors.elementAt(index);
        final onBackground = color.computeForegroundColor();
        return Card(
          color: color,
          child: InkWell(
            onTap: () {
              if (selected.value.value == color.value) {
                Navigator.of(context).pop();
                print('pop');
                return onSelected(color);
              }
              selected.value = color;
            },
            child: Opacity(
              opacity: .5 - color.computeLuminance() / 4,
              child: Center(
                child: AnimatedSwitcher(
                  duration: kThemeChangeDuration,
                  switchInCurve: Curves.ease,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: color.value == selected.value.value
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
        final color = colors.elementAt(index);
        if (color.value == initial.value) {
          return const StaggeredTile.count(2, 2);
        }
        // final mod = index % widthFreq;
        // final check = widthFreq - 1;
        // final wide = mod == check;
        // print("$mod == $check = $wide");
        // return StaggeredTile.count(wide ? 2 : 1, 1);
        return StaggeredTile.count(1, 1);
      },
    );
  }
}

class UseSslCard extends StatelessWidget {
  const UseSslCard({
    Key? key,
    required this.pi,
    required this.onChanged,
    required this.onTap,
  }) : super(key: key);

  final Pi pi;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DoublePiGridCard(
      left: Center(child: TileTitle('Use SSL')),
      right: Center(
        child: Checkbox(
          // activeColor: pi.primaryColor,
          // checkColor: pi.primaryColor.computeForegroundColor(),
          value: pi.useSsl,
          onChanged: onChanged,
        ),
      ),
      onTap: onTap,
    );
  }
}

class SummaryTestTile extends HookWidget {
  const SummaryTestTile({
    Key? key,
    required this.pi,
  }) : super(key: key);

  final Pi pi;

  @override
  Widget build(BuildContext context) {
    final summaryValue = useProvider(piSummaryProvider(pi));

    final VoidCallback onTap = () {
      final dialog = summaryValue.maybeWhen(
        data: (summary) => DialogListBase(
          header: DialogHeader(title: 'Success'),
          body: SliverToBoxAdapter(
            child: ExpandableCode(
              summary.toString(),
              expanded: false,
              tappable: false,
            ),
          ),
        ),
        error: (e, s) => DialogListBase(
          header: DialogHeader(title: e.toString()),
          body: SliverToBoxAdapter(
            child: ExpandableCode(s.toString()),
          ),
        ),
        orElse: () => null,
      );

      if (dialog != null) {
        showModal(
          context: context,
          builder: (context) {
            return dialog;
          },
        );
      }
    };

    return DoublePiGridCard(
      onTap: onTap,
      left: Center(child: Text('Summary')),
      right: IconButton(
        icon: Icon(
          KIcons.dot,
          color: summaryValue.when(
            data: (data) => KColors.success,
            loading: () => KColors.loading,
            error: (error, stacktrace) => KColors.error,
          ),
          size: 8.0,
        ),
        onPressed: onTap,
      ),
    );
  }
}

class VersionsTestTile extends HookWidget {
  const VersionsTestTile({
    Key? key,
    required this.pi,
  }) : super(key: key);

  final Pi pi;

  @override
  Widget build(BuildContext context) {
    final versionsValue = useProvider(topItemsProvider(pi));

    final VoidCallback onTap = () {
      final dialog = versionsValue.maybeWhen(
        data: (versions) => DialogListBase(
          header: DialogHeader(title: 'Success'),
          body: SliverToBoxAdapter(
            child: ExpandableCode(
              versions.toString(),
              expanded: false,
              tappable: false,
            ),
          ),
        ),
        error: (e, s) => DialogListBase(
          header: DialogHeader(title: e.toString()),
          body: SliverToBoxAdapter(
            child: ExpandableCode(s.toString()),
          ),
        ),
        orElse: () => null,
      );

      if (dialog != null) {
        showModal(
          context: context,
          builder: (context) {
            return dialog;
          },
        );
      }
    };

    return DoublePiGridCard(
      onTap: onTap,
      left: Center(child: Text('Top items')),
      right: IconButton(
        icon: Icon(
          KIcons.dot,
          color: versionsValue.when(
            data: (data) => KColors.success,
            loading: () => KColors.loading,
            error: (error, stacktrace) => KColors.error,
          ),
          size: 8.0,
        ),
        onPressed: onTap,
      ),
    );
  }
}

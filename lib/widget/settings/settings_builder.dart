import 'package:flutter/material.dart';
import 'package:flutterhole/widget/layout/list_tab.dart';
import 'package:flutterhole/widget/pihole/pihole_list_builder.dart';
import 'package:persist_theme/persist_theme.dart';

class SettingsBuilder extends StatefulWidget {
  const SettingsBuilder({
    Key key,
  }) : super(key: key);

  @override
  _SettingsBuilderState createState() => _SettingsBuilderState();
}

class _SettingsBuilderState extends State<SettingsBuilder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTab('Pihole settings'),
        PiholeListBuilder(),
        ListTab('Theme'),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            DarkModeSwitch(),
            CustomThemeSwitch(),
            Row(
              children: <Widget>[
                Flexible(child: PrimaryColorPicker()),
                Flexible(child: AccentColorPicker()),
              ],
            ),
            DarkAccentColorPicker(),
          ],
        ),
      ],
    );
  }
}

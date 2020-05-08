import 'package:flutter/material.dart';
import 'package:flutterhole/constants.dart';
import 'package:flutterhole/features/settings/data/models/pihole_settings.dart';

class PiholeSettingsTile extends StatelessWidget {
  const PiholeSettingsTile({
    Key key,
    @required this.settings,
    @required this.isActive,
    this.onTap,
  }) : super(key: key);

  final PiholeSettings settings;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${settings.title}'),
      onTap: onTap,
      trailing: AnimatedOpacity(
        duration: kThemeAnimationDuration,
        opacity: isActive ? 1 : 0,
        child: Icon(KIcons.success),
      ),
    );
  }
}

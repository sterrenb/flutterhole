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
      subtitle:
          settings.description.isEmpty ? null : Text('${settings.description}'),
      onTap: onTap,
      leading: Icon(
        KIcons.color,
        color: settings.primaryColor,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Visibility(
            visible: isActive,
            child: IconButton(
              icon: Icon(
                KIcons.success,
              ),
              onPressed: null,
            ),
          ),
          Icon(KIcons.open),
        ],
      ),
    );
  }
}

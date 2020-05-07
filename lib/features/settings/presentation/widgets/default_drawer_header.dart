import 'package:flutter/material.dart';
import 'package:flutterhole/features/settings/presentation/widgets/active_pihole_title.dart';

class DefaultDrawerHeader extends StatelessWidget {
  const DefaultDrawerHeader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: ActivePiholeTitle(),
      accountEmail: null,
    );
  }
}

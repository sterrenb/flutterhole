import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/routing/services/router_service.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    Key key,
    @required this.title,
    @required this.icon,
    @required this.routeName,
  }) : super(key: key);

  final Widget title;
  final Widget icon;
  final String routeName;

  bool _isActive(BuildContext context) =>
      ModalRoute.of(context)?.settings?.name == routeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _isActive(context)
          ? BoxDecoration(
        color: Theme.of(context).accentColor.withOpacity(0.2),
      )
          : null,
      child: ListTile(
        title: title,
        leading: icon,
        onTap: () {
          getIt<RouterService>().pushFromRoot(routeName);
        },
      ),
    );
  }
}

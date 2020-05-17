import 'package:flutter/material.dart';
import 'package:flutterhole/dependency_injection.dart';
import 'package:flutterhole/features/settings/services/preference_service.dart';
import 'package:flutterhole/widgets/layout/dialogs.dart';

/// Calls [showWelcomeDialog] if this is the first time the app is launched.
class WelcomeMessageChecker extends StatefulWidget {
  const WelcomeMessageChecker({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _WelcomeMessageCheckerState createState() => _WelcomeMessageCheckerState();
}

class _WelcomeMessageCheckerState extends State<WelcomeMessageChecker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (getIt<PreferenceService>().checkFirstUse()) {
        showWelcomeDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

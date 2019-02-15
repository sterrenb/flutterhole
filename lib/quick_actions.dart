import 'package:quick_actions/quick_actions.dart';
import 'package:sterrenburg.github.flutterhole/api_provider.dart';

/// Adds quick actions to the home screen app icon.
void quickActions() {
  final ApiProvider provider = ApiProvider();
  final QuickActions quickActions = QuickActions();
  quickActions.initialize((shortcutType) {
    bool newStatus;
    switch (shortcutType) {
      case 'action_disable':
        newStatus = false;
        break;
      case 'action_enable':
        newStatus = true;
        break;
      default:
        throw Exception('Invalid shortcutType: $shortcutType');
    }

    provider.setStatus(newStatus);
  });

  quickActions.setShortcutItems(<ShortcutItem>[
    ShortcutItem(
      type: 'action_disable',
      localizedTitle: 'Disable',
    ),
    ShortcutItem(
      type: 'action_enable',
      localizedTitle: 'Enable',
    ),
  ]);
}

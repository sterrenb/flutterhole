import 'package:flutter/widgets.dart';

class DrawerNotifier extends ChangeNotifier {
  bool _expanded = false;

  bool get isExpanded => _expanded;

  void toggle() {
    _expanded = !_expanded;
    notifyListeners();
  }
}
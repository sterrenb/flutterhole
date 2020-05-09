import 'package:flutter/widgets.dart';

class PieChartNotifier extends ChangeNotifier {
  int _selected = -1;

  int get selected => _selected;

  set selected(int value) {
    _selected = value;
    notifyListeners();
  }
}

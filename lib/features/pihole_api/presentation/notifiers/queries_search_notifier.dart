import 'package:flutter/material.dart';

class QueriesSearchNotifier extends ChangeNotifier {
  bool _isSearching = false;
  String _searchQuery = '';

  bool get isSearching => _isSearching;

  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value.toLowerCase();
    notifyListeners();
  }

  void startSearching() {
    _isSearching = true;
    _searchQuery = '';
    notifyListeners();
  }

  void stopSearching() {
    _isSearching = false;
    _searchQuery = '';
    notifyListeners();
  }
}

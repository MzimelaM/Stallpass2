// lib/state/app_state.dart
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  int? _userId;

  int? get userId => _userId;

  void setUserId(int? userId) {
    _userId = userId;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../models.dart';

class AppState extends ChangeNotifier {
  int? _userId;
  int? get userId => _userId;
  int _score = 0;
  int _streak = 0; 
  final Set<String> _completedStallIds = {};

  int get score => _score;
  int get streak => _streak;
  Set<String> get completedStallIds => _completedStallIds;

  void addScore(int delta) {
    _score += delta;
    notifyListeners();
  }

  void markStallCompleted(Stall stall) {
    if (_completedStallIds.add(stall.id)) {
      _streak = _completedStallIds.length;
      notifyListeners();
    }
  }

  bool isStallCompleted(String stallId) => _completedStallIds.contains(stallId);

  void resetProgress() {
    _score = 0;
    _streak = 0;
    _completedStallIds.clear();
    notifyListeners();
  }
  void setUserId(dynamic newUserId) {
    if (newUserId is int) {
      _userId = newUserId;
    } else if (newUserId is String) {
      _userId = int.tryParse(newUserId);
    }
    notifyListeners();
  }


}


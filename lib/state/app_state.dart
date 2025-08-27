import 'package:flutter/foundation.dart';
//import '../models.dart';

class AppState extends ChangeNotifier {
  String? _studentNumber; // use String now
  int _score = 0;
  int _streak = 0;
  final Set<String> _completedStallIds = {};

  String? get studentNumber => _studentNumber;
  int get score => _score;
  int get streak => _streak;
  Set<String> get completedStallIds => _completedStallIds;

  void setStudentNumber(String newStudentNumber) {
    _studentNumber = newStudentNumber;
    notifyListeners();
  }

  void addScore(int delta) {
    _score += delta;
    notifyListeners();
  }

  //void markStallCompleted(Stall stall) {
   // if (_completedStallIds.add(stall.id)) {
   //   _streak = _completedStallIds.length;
   //   notifyListeners();
   // }
 // }

  bool isStallCompleted(String stallId) => _completedStallIds.contains(stallId);

  void resetProgress() {
    _score = 0;
    _streak = 0;
    _completedStallIds.clear();
    notifyListeners();
  }
}

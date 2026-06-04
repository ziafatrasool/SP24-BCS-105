import 'package:flutter/material.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<dynamic> _users = [];

  List<dynamic> get users => _users;

  void setUsers(List<dynamic> users) {
    _users = users;

    notifyListeners();
  }

  void clearLeaderboard() {
    _users.clear();

    notifyListeners();
  }
}

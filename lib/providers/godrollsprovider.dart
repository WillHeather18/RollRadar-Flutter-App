import 'package:flutter/foundation.dart';

class GodRollsProvider with ChangeNotifier {
  List<dynamic> _godRolls = [];

  List<dynamic> get godRolls => _godRolls;

  void setGodRolls(List<dynamic> newGodRolls) {
    _godRolls = newGodRolls;
    notifyListeners();
  }
}

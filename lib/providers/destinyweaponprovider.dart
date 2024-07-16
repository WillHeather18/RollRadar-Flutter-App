import 'package:flutter/material.dart';

class DestinyWeaponProvider with ChangeNotifier {
  Map<String, dynamic> _destinyWeapons = {};

  Map<String, dynamic> get destinyWeapons => _destinyWeapons;

  void setWeapons(Map<String, dynamic> weapons) {
    _destinyWeapons = weapons;
    notifyListeners();
  }

  dynamic getWeapon(String hash) {
    return _destinyWeapons[hash];
  }
}

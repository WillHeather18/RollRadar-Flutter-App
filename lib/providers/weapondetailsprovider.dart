import 'package:flutter/foundation.dart';

class WeaponDetailsProvider with ChangeNotifier {
  List<dynamic> _weaponDetails = [];

  List<dynamic> get weaponDetails => _weaponDetails;

  void setWeaponDetails(List<dynamic> newWeaponDetails) {
    _weaponDetails = newWeaponDetails;
    notifyListeners();
  }
}

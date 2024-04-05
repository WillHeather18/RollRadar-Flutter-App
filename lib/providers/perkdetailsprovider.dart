import 'package:flutter/foundation.dart';

class PerkDetailsProvider with ChangeNotifier {
  List<dynamic> _perkDetails = [];

  List<dynamic> get perkDetails => _perkDetails;

  void setPerkDetails(List<dynamic> newPerkDetails) {
    _perkDetails = newPerkDetails;
    notifyListeners();
  }
}

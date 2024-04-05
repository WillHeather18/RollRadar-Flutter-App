import 'package:flutter/foundation.dart';

class CharacterDetailsProvider with ChangeNotifier {
  Map<String, dynamic> _characterDetails = {};

  Map<String, dynamic> get characterDetails => _characterDetails;

  void setCharacterDetails(Map<String, dynamic> newCharacterDetails) {
    _characterDetails = newCharacterDetails;
    notifyListeners();
  }
}

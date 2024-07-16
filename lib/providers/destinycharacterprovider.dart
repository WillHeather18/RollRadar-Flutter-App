import 'package:bungie_api/destiny2.dart';
import 'package:flutter/foundation.dart';

class DestinyCharacterProvider with ChangeNotifier {
  Map<String, DestinyCharacterComponent> _characters = {};

  Map<String, DestinyCharacterComponent> get characters => _characters;

  void setCharacters(Map<String, DestinyCharacterComponent> allCharacters) {
    _characters = allCharacters;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class BungieIdProvider with ChangeNotifier {
  String _bungieId = 'No membership ID';

  String get bungieId => _bungieId;

  void setBungieId(String value) {
    _bungieId = value;
  }
}

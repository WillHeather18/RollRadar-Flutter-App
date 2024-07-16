import 'package:flutter/foundation.dart';

class BungieIdProvider with ChangeNotifier {
  String _bungieId = 'No membership ID';
  String _membershipType = 'No membership type';
  String _destinyMembershipId = 'No destiny membership ID';

  String get bungieId => _bungieId;
  String get membershipType => _membershipType;
  String get destinyMembershipId => _destinyMembershipId;

  void setBungieId(String value) {
    _bungieId = value;
  }

  void setMembershipType(String value) {
    _membershipType = value;
  }

  void setDestinyMembershipId(String value) {
    _destinyMembershipId = value;
  }
}

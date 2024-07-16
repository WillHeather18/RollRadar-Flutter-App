import 'package:bungie_api/models/general_user.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  GeneralUser _user = GeneralUser();
  String _bungieID = '';
  String _membershipId = '';
  String _membershipType = '';
  Map<String, dynamic> _preferences = {};

  GeneralUser get user => _user;
  String get bungieID => _bungieID;
  String get membershipID => _membershipId;
  String get membershipType => _membershipType;
  Map<String, dynamic> get userPreferences => _preferences;

  void setUser(GeneralUser user) {
    _user = user;
    notifyListeners();
  }

  void setBungieId(String id) {
    _bungieID = id;
    notifyListeners();
  }

  void setUserPreferences(Map<String, dynamic> prefs) {
    _preferences = prefs;
    notifyListeners();
  }

  void setMembershipId(String id) {
    _membershipId = id;
    notifyListeners();
  }

  void setMembershipType(String type) {
    _membershipType = type;
    notifyListeners();
  }
}

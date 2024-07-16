import 'package:bungie_api/models/general_user.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  GeneralUser _user = GeneralUser();
  String bungieID = '';

  GeneralUser get user => _user;
  String get bungieId => bungieID;

  void setUser(GeneralUser user) {
    _user = user;
    notifyListeners();
  }

  void setBungieId(String id) {
    bungieID = id;
    notifyListeners();
  }
}

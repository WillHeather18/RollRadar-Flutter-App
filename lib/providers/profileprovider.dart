import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bungieidprovider.dart';
import 'package:http/http.dart' as http;

class ProfileProvider with ChangeNotifier {
  Map<String, dynamic> _profile = {};

  Map<String, dynamic> get profile => _profile;

  void setProfile(Map<String, dynamic> newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  Future<void> refreshProfile(BuildContext context) async {
    var bungieIdProvider =
        Provider.of<BungieIdProvider>(context, listen: false);
    var bungieID = bungieIdProvider.bungieId;

    final response = await http.get(Uri.parse(
        'https://rollradaroauth.azurewebsites.net/getprofile/$bungieID'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setProfile(jsonResponse);
    } else {
      throw Exception('Failed to load data');
    }

    notifyListeners();
  }
}

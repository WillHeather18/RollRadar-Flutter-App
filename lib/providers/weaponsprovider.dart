import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profileprovider.dart';
import 'package:http/http.dart' as http;

class WeaponsProvider with ChangeNotifier {
  List<dynamic> _weapons = [];

  List<dynamic> get weapons => _weapons;

  void setWeapons(List<dynamic> newWeapons) {
    _weapons = newWeapons;
    notifyListeners();
  }

  Future<void> refreshWeapons(BuildContext context) async {
    var profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.refreshProfile(context);
    var profile = profileProvider.profile;

    var bungieId = profile['bungie_id'];
    var membershipType = profile['membership_type'];
    var accessToken = profile['access_token'];
    var destinyMembershipId = profile['destiny_membership_id'];

    final response = await http.post(
      Uri.parse(
          'https://rollradarazurefunctions.azurewebsites.net/api/dailyinvscan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'bungie_id': bungieId,
        'membership_type': membershipType,
        'access_token': accessToken,
        'destiny_membership_id': destinyMembershipId,
      }),
    );

    if (response.statusCode == 200) {
      print("Weapons loaded successfully");
      var jsonResponse = jsonDecode(response.body);
      setWeapons(jsonResponse['weapons']);
    } else {
      throw Exception('Failed to load data');
    }

    notifyListeners();
  }
}

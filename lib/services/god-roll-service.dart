import 'dart:convert';
import 'package:bungie_api/destiny2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GodRollService {
  Future<Map<String, dynamic>?> getGodRoll(String hash) async {
    CollectionReference godRollsCollection =
        FirebaseFirestore.instance.collection('GodRolls');

    DocumentSnapshot docSnapshot = await godRollsCollection.doc(hash).get();

    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>?;
    } else {
      return null;
    }
  }

  bool isPerkGodRoll(
      Map<String, dynamic> godroll, int perkHash, String perkName, int index) {
    List<dynamic> socketDetailsList =
        jsonDecode(godroll['sockets_details'][index]);
    if (socketDetailsList[0]['socketHash'] == perkHash ||
        socketDetailsList[0]['name'] == perkName) {
      return true;
    } else {
      return false;
    }
  }

  String calculateSlotPosition(
      Map<String, dynamic> godroll, int perkHash, String perkName, int index) {
    var slotPercentage = '';
    List<dynamic> socketDetailsList =
        jsonDecode(godroll['sockets_details'][index]);

    final socketDetailsLength = socketDetailsList.length;

    for (int i = 0; i < socketDetailsLength; i++) {
      if (socketDetailsList[i]['socketHash'] == perkHash ||
          socketDetailsList[i]['name'] == perkName) {
        slotPercentage = "${i + 1}/$socketDetailsLength";
        break;
      }
    }
    return slotPercentage;
  }

  double calculateWeaponPercentage(Map<String, dynamic> godroll,
      List<List<DestinyInventoryItemDefinition>> allWeaponPerks) {
    List<double> slotScores = List.filled(4, 0.0);
    for (var i = 0; i < 4; i++) {
      final slotPerks = jsonDecode(godroll['sockets_details'][i]);
      final weaponSlotPerks = allWeaponPerks[i];
      final topPerkPopularityString = slotPerks[0]['percentage'];
      final topPerkPopularity =
          double.parse(topPerkPopularityString.replaceAll('%', ''));
      int slotBestPerkIndex = 99;
      for (var perk in weaponSlotPerks) {
        var count = 0;
        for (var perkOption in slotPerks) {
          if (perk.hash == perkOption['socketHash'] ||
              perk.displayProperties?.name == perkOption['name']) {
            if (slotBestPerkIndex > count) {
              slotBestPerkIndex = count;
            }
          }
          count++;
        }
      }
      final perkPopularityString = slotPerks[slotBestPerkIndex]['percentage'];
      final perkPopularity =
          double.parse(perkPopularityString.replaceAll('%', ''));
      slotScores[i] = perkPopularity / topPerkPopularity;
    }
    double scoresCombined = 0;
    for (var score in slotScores) {
      scoresCombined += score;
    }
    double averageScore = scoresCombined / slotScores.length;
    return averageScore * 100;
  }
}

class GodRollResult {
  final int score;
  final double percentage;

  GodRollResult({required this.score, required this.percentage});
}

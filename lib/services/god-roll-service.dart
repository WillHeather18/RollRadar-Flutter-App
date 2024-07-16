import 'dart:convert';
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
    print(socketDetailsList);
    if (socketDetailsList[0]['socketHash'] == perkHash ||
        socketDetailsList[0]['name'] == perkName) {
      return true;
    } else {
      return false;
    }
  }
}

class GodRollResult {
  final int score;
  final double percentage;

  GodRollResult({required this.score, required this.percentage});
}

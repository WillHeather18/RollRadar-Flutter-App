import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreListener {
  final String bungieID;
  final Function(List<dynamic>) onWeaponsUpdated;

  FirestoreListener({required this.bungieID, required this.onWeaponsUpdated});

  void initialize() {
    print("listening to firestore");
    print("bungieID: $bungieID");
    FirebaseFirestore.instance
        .collection('RecentWeapons')
        .doc("recent")
        .snapshots()
        .listen((documentSnapshot) {
      if (documentSnapshot.exists) {
        print("document exists");
        List<dynamic> instanceIds = documentSnapshot['instance_ids'];
        print("Total instance ids retrieved: ${instanceIds.length}");
        instanceIds.sort((a, b) => b.compareTo(a)); // Sort in descending order
        var topTwentyInstanceIds = instanceIds.toList(); // Take top 20
        print(
            "Number of instance ids after taking top 20: ${topTwentyInstanceIds.length}");
        onWeaponsUpdated(topTwentyInstanceIds);
      }
    });
  }
}

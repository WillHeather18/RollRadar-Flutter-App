import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferenceService {
  Future<Map<String, dynamic>?> getPreferences(String userId) async {
    try {
      var preferences = await FirebaseFirestore.instance
          .collection('UserPreferences')
          .doc(userId)
          .get();
      print('Preferences retrieved successfully: $preferences');
      return preferences.data();
    } catch (e) {
      print('Error retrieving preferences: $e');
      throw e; // Rethrow the error or handle it as needed
    }
  }

  void savePreferences(
      String userId,
      bool autoLockGodRolls,
      bool autoVaultGodRolls,
      bool weaponTraitsOnly,
      int requiredPerksForGodRoll) async {
    var preferences = {
      'autoLockGodRolls': autoLockGodRolls,
      'autoVaultGodRolls': autoVaultGodRolls,
      'weaponTraitsOnly': weaponTraitsOnly,
      'requiredPerksForGodRoll': requiredPerksForGodRoll,
    };

    try {
      await FirebaseFirestore.instance
          .collection('UserPreferences')
          .doc(userId)
          .set(preferences);
      print('Preferences saved successfully');
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }
}

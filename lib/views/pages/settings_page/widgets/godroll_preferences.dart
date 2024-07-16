import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/providers/bungieidprovider.dart';
import 'package:provider/provider.dart';

class GodRollPreferences extends StatefulWidget {
  @override
  _GodRollPreferencesState createState() => _GodRollPreferencesState();
}

class _GodRollPreferencesState extends State<GodRollPreferences> {
  bool _toggle1 = false;
  bool _toggle2 = false;
  bool _toggle3 = false;
  int _selectedNumber = 4;
  int _selectedNumberHolder = 4;

  void savePreferences(String userId) async {
    var preferences = {
      'autoLockGodRolls': _toggle1,
      'autoVaultGodRolls': _toggle2,
      'weaponTraitsOnly': _toggle3,
      'requiredPerksForGodRoll': _selectedNumber,
    };

    try {
      // Assuming you have a user ID to use as a document reference.
      // This could be from Firebase Auth or another source.
      await FirebaseFirestore.instance
          .collection('UserPreferences')
          .doc(userId)
          .set(preferences);
      print('Preferences saved successfully');
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    BungieIdProvider bungieIdProvider = Provider.of(context);
    final bungieId = bungieIdProvider.bungieId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('God Roll Preferences'),
      ),
      body: Stack(children: [
        ListView(
          children: [
            ListTile(
              title: const Text('Auto-Lock God Rolls'),
              trailing: Switch(
                value: _toggle1,
                onChanged: (value) {
                  setState(() {
                    _toggle1 = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Auto-Vault God Rolls'),
              trailing: Switch(
                value: _toggle2,
                onChanged: (value) {
                  setState(() {
                    _toggle2 = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Weapon Traits Only'),
              trailing: Switch(
                value: _toggle3,
                onChanged: (value) {
                  setState(() {
                    _toggle3 = value;
                    if (value == true) {
                      _selectedNumberHolder = 2;
                    } else {
                      _selectedNumberHolder = _selectedNumber;
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Required Perks for God Roll'),
              trailing: AbsorbPointer(
                absorbing:
                    _toggle3, // Disable interactions when _toggle3 is true
                child: DropdownButton<int>(
                  value: _selectedNumberHolder,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: TextStyle(
                      color: _toggle3
                          ? Colors.grey
                          : Colors
                              .deepPurple), // Change color based on _toggle3
                  underline: Container(
                    height: 2,
                    color: _toggle3
                        ? Colors.grey
                        : Colors
                            .deepPurpleAccent, // Change underline color based on _toggle3
                  ),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedNumber = newValue!;
                      _selectedNumberHolder = newValue;
                    });
                  },
                  items:
                      <int>[1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: ElevatedButton(
                onPressed: () {
                  savePreferences(bungieId);
                },
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

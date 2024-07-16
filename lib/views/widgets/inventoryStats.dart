import 'package:flutter/material.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import '../widgets/item_icon.dart';
import 'package:provider/provider.dart';

class InventoryStats extends StatelessWidget {
  final List<dynamic> weaponDetailsList;
  final List<dynamic> perkDetailsList;

  InventoryStats(
      {required this.weaponDetailsList, required this.perkDetailsList});

  @override
  Widget build(BuildContext context) {
    var weaponsProvider = Provider.of<DestinyProfileProvider>(context);
    var weaponsList = weaponsProvider.weapons;

    var weaponHashCount = <int, int>{};

    for (var weapon in weaponsList) {
      var weaponHash = weapon['weaponHash'] as int;
      weaponHashCount[weaponHash] = (weaponHashCount[weaponHash] ?? 0) + 1;
    }

    var mostCommonWeaponHash = weaponHashCount.keys
        .reduce((a, b) => weaponHashCount[a]! > weaponHashCount[b]! ? a : b);

    print('Most common weaponHash: $mostCommonWeaponHash');

    var mostCommonWeapon = weaponDetailsList
        .firstWhere((element) => element['id'] == mostCommonWeaponHash);

    var perkHashCount = <String, int>{};
    for (var weapon in weaponsList) {
      var weaponPerks = (weapon['socketHashes'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();
      for (var perkHash in weaponPerks) {
        perkHashCount[perkHash] = (perkHashCount[perkHash] ?? 0) + 1;
      }
    }

    var mostCommonPerkHash = perkHashCount.keys
        .reduce((a, b) => perkHashCount[a]! > perkHashCount[b]! ? a : b);

    print('Most common perkHash: $mostCommonPerkHash');

    var mostCommonPerk = perkDetailsList.firstWhere(
        (element) => element['hash'].toString() == mostCommonPerkHash);

    print("Most common perk: $mostCommonPerk");

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1f2233),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              'Total Weapons: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            trailing: Text(
              '${weaponsList.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
              title: const Text(
                'Most Common Weapon: ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${mostCommonWeapon['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              trailing: WeaponIcon(
                destinyWeapon: mostCommonWeapon,
                showDetails: false,
              )),
          ListTile(
            title: const Text(
              'Most Common Perk: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${mostCommonPerk['displayProperties']['name']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            trailing: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.lightBlue,
              backgroundImage: NetworkImage(
                "https://www.bungie.net${mostCommonPerk['displayProperties']['icon']}",
              ),
            ),
          )
        ],
      ),
    );
  }
}

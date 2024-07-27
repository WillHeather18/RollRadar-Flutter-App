import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/providers/profileprovider.dart';

class DestinyPerkProvider with ChangeNotifier {
  Map<String, dynamic> _destinyPerks = {};
  Map<String, dynamic> _destinyPlugSets = {};

  Map<String, dynamic> get destinyPerks => _destinyPerks;
  Map<String, dynamic> get destinyPlugSets => _destinyPlugSets;

  void setPerks(Map<String, dynamic> perks) {
    _destinyPerks = perks;
    notifyListeners();
  }

  void setPlugSets(Map<String, dynamic> plugSets) {
    _destinyPlugSets = plugSets;
    notifyListeners();
  }

  DestinyInventoryItemDefinition? getPerk(String hash) {
    final perk = _destinyPerks[hash];
    if (perk == null) {
      return null;
    }
    DestinyInventoryItemDefinition perkDefinition =
        DestinyInventoryItemDefinition.fromJson(perk);
    return perkDefinition;
  }

  List<List<DestinyInventoryItemDefinition>> getAllWeaponPerks(
      FullItem weapon) {
    List<List<DestinyInventoryItemDefinition>> allPerks = [];
    final perkOptions = weapon.randomPlugs;
    if (weapon.randomPlugs != null) {
      for (var i = 1; i < 5; i++) {
        List<DestinyInventoryItemDefinition> slotPerks = [];
        final perkIndex = perkOptions?[i.toString()];
        if (perkIndex != null) {
          for (var perk in perkIndex!) {
            final perkDef = getPerk(perk.plugItemHash.toString());
            if (perkDef != null) {
              slotPerks.add(perkDef);
            }
          }
        } else {
          var perkSocketHash = weapon.sockets?[i].plugHash.toString();
          final perkDef = getPerk(perkSocketHash!);
          slotPerks.add(perkDef!);
        }
        allPerks.add(slotPerks);
      }
    } else {
      for (var i = 1; i < 5; i++) {
        List<DestinyInventoryItemDefinition> slotPerks = [];
        var perkSocketHash = weapon.sockets?[i].plugHash.toString();
        if (perkSocketHash == null) {
          continue;
        }
        final perkDef = getPerk(perkSocketHash);
        if (perkDef != null) {
          slotPerks.add(perkDef);
        }
        allPerks.add(slotPerks);
      }
    }

    return allPerks;
  }
}

import 'package:bungie_api/destiny2.dart';

dynamic damageLookup(int damageType) {
  switch (damageType) {
    case 1:
      return {
        'name': 'Kinetic',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_3385a924fd3ccb92c343ade19f19a370.png',
      };
    case 2:
      return {
        'name': 'Arc',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_092d066688b879c807c3b460afdd61e6.png',
      };
    case 3:
      return {
        'name': 'Solar',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_2a1773e10968f2d088b97c22b22bba9e.png',
      };
    case 4:
      return {
        'name': 'Void',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_ceb2f6197dccf3958bb31cc783eb97a0.png',
      };
    case 6:
      return {
        'name': 'Stasis',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_530c4c3e7981dc2aefd24fd3293482bf.png',
      };
    case 7:
      return {
        'name': 'Strand',
        'icon':
            '/common/destiny2_content/icons/DestinyDamageTypeDefinition_b2fe51a94f3533f97079dfa0d27a4096.png',
      };
    default:
      return {
        'name': 'Unknown',
        'icon': 'Unknown',
      };
  }
}

Map<DamageType, String> damageIconLookup = {
  DamageType.Kinetic:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_3385a924fd3ccb92c343ade19f19a370.png',
  DamageType.Arc:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_092d066688b879c807c3b460afdd61e6.png',
  DamageType.Thermal:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_2a1773e10968f2d088b97c22b22bba9e.png',
  DamageType.Void:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_ceb2f6197dccf3958bb31cc783eb97a0.png',
  DamageType.Stasis:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_530c4c3e7981dc2aefd24fd3293482bf.png',
  DamageType.Strand:
      '/common/destiny2_content/icons/DestinyDamageTypeDefinition_b2fe51a94f3533f97079dfa0d27a4096.png',
};

String getDamageIcon(DamageType damageType) {
  return damageIconLookup[damageType] ?? 'Unknown';
}

String Function(int) attackTypeLookup = (int attackType) {
  switch (attackType) {
    case 1498876634:
      return 'Kinetic';
    case 2465295065:
      return 'Energy';
    case 953998645:
      return 'Heavy';
    default:
      return 'Unknown';
  }
};

String Function(int) ammoTypeLookup = (int ammoType) {
  switch (ammoType) {
    case 1:
      return 'Primary';
    case 2:
      return 'Special';
    case 3:
      return 'Heavy';
    default:
      return 'Unknown';
  }
};

Map<DestinyAmmunitionType, int> ammoTypeMap = {
  DestinyAmmunitionType.Primary: 0,
  DestinyAmmunitionType.Special: 1,
  DestinyAmmunitionType.Heavy: 2,
  DestinyAmmunitionType.Unknown: 3,
};

int getAmmoType(DestinyAmmunitionType ammoType) {
  return ammoTypeMap[ammoType] ?? 0;
}

String? statNameLookup(int statHash) {
  const Map<int, String> statNameLookup = {
    2223994109: "Aspect Energy Capacity",
    2341766298: "Handicap",
    2399985800: "Void Cost",
    2441327376: "Armor Energy Capacity",
    2523465841: "Velocity",
    2714457168: "Airborne Effectiveness",
    2715839340: "Recoil Direction",
    2733264856: "Score Multiplier",
    2762071195: "Guard Efficiency",
    2837207746: "Swing Speed",
    2961396640: "Charge Time",
    2996146975: "Mobility",
    3017642079: "Boost",
    3022301683: "Charge Rate",
    3289069874: "Power Bonus",
    3344745325: "Solar Cost",
    3555269338: "Zoom",
    3578062600: "Any Energy Type Cost",
    3597844532: "Precision Damage",
    3614673599: "Blast Radius",
    3625423501: "Armor Energy Capacity",
    3736848092: "Guard Endurance",
    3779394102: "Arc Cost",
    3871231066: "Magazine",
    3897883278: "Defense",
    3907551967: "Move Speed",
    3950461274: "Armor Energy Capacity",
    3988418950: "Time to Aim Down Sights",
    4043523819: "Impact",
    4188031367: "Reload Speed",
    4244567218: "Strength",
    4284893193: "Rounds Per Minute",
    16120457: "Armor Energy Capacity",
    119204074: "Fragment Cost",
    144602215: "Intellect",
    155624089: "Stability",
    209426660: "Guard Resistance",
    237763788: "Ghost Energy Capacity",
    360359141: "Durability",
    392767087: "Resilience",
    447667954: "Draw Time",
    514071887: "Mod Cost",
    925767036: "Ammo Capacity",
    943549884: "Handling",
    998798867: "Stasis Cost",
    1240592695: "Range",
    1345609583: "Aim Assistance",
    1480404414: "Attack",
    1501155019: "Speed",
    1546607977: "Heroic Resistance",
    1546607978: "Arc Damage Resistance",
    1546607979: "Solar Damage Resistance",
    1546607980: "Void Damage Resistance",
    1591432999: "Accuracy",
    1735777505: "Discipline",
    1842278586: "Shield Duration",
    1931675084: "Inventory Size",
    1935470627: "Power",
    1943323491: "Recovery",
    2018193158: "Armor Energy Capacity"
  };

  return statNameLookup[statHash];
}

String classTypeLookup(int classId) {
  const classLookup = {0: 'Titan', 1: 'Hunter', 2: 'Warlock'};

  return classLookup[classId] ?? "Unknown";
}

String raceTypeLookup(int raceId) {
  const raceLookup = {0: 'Human', 1: 'Awoken', 2: 'Exo'};

  return raceLookup[raceId] ?? "Unknown";
}

String genderTypeLookup(int genderId) {
  const genderLookup = {0: 'Male', 1: 'Female'};

  return genderLookup[genderId] ?? "Unknown";
}

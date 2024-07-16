import 'dart:convert';

class Combo {
  String percentage;
  String perk1Hash;
  String perk2Hash;

  Combo({
    required this.percentage,
    required this.perk1Hash,
    required this.perk2Hash,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      percentage: json['percentage'],
      perk1Hash: json['perk1_hash'],
      perk2Hash: json['perk2_hash'],
    );
  }
}

class Masterwork {
  String id;
  String imageUrl;
  String name;
  String percentage;

  Masterwork({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.percentage,
  });

  factory Masterwork.fromJson(Map<String, dynamic> json) {
    return Masterwork(
      id: json['id'],
      imageUrl: json['image_url'],
      name: json['name'],
      percentage: json['percentage'],
    );
  }
}

class Mod {
  String id;
  String imageUrl;
  String name;
  String percentage;

  Mod({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.percentage,
  });

  factory Mod.fromJson(Map<String, dynamic> json) {
    return Mod(
      id: json['id'],
      imageUrl: json['image_url'],
      name: json['name'],
      percentage: json['percentage'],
    );
  }
}

class SocketDetail {
  String percentage;
  String name;
  int socketHash;

  SocketDetail({
    required this.percentage,
    required this.name,
    required this.socketHash,
  });

  factory SocketDetail.fromJson(Map<String, dynamic> json) {
    return SocketDetail(
      percentage: json['percentage'],
      name: json['name'],
      socketHash: json['socketHash'],
    );
  }
}

class TheoryCraft {
  int category;
  String dataId;

  TheoryCraft({
    required this.category,
    required this.dataId,
  });

  factory TheoryCraft.fromJson(Map<String, dynamic> json) {
    return TheoryCraft(
      category: json['category'],
      dataId: json['data_id'],
    );
  }
}

class GodRoll {
  List<Combo> combos;
  List<Masterwork> masterworks;
  List<Mod> mods;
  List<List<SocketDetail>> socketsDetails;
  List<TheoryCraft> theoryCraft;
  int weaponHash;

  GodRoll({
    required this.combos,
    required this.masterworks,
    required this.mods,
    required this.socketsDetails,
    required this.theoryCraft,
    required this.weaponHash,
  });

  factory GodRoll.fromJson(Map<String, dynamic> json) {
    var combosFromJson = json['combos'] as List;
    List<Combo> comboList =
        combosFromJson.map((combo) => Combo.fromJson(combo)).toList();

    var masterworksFromJson = json['masterworks'] as List;
    List<Masterwork> masterworkList =
        masterworksFromJson.map((mw) => Masterwork.fromJson(mw)).toList();

    var modsFromJson = json['mods'] as List;
    List<Mod> modList = modsFromJson.map((mod) => Mod.fromJson(mod)).toList();

    var socketsFromJson = json['sockets_details'] as List;
    List<List<SocketDetail>> socketList = socketsFromJson.map((socket) {
      var socketDetailList = jsonDecode(socket) as List;
      return socketDetailList
          .map((detail) => SocketDetail.fromJson(detail))
          .toList();
    }).toList();

    var theoryCraftFromJson = json['theory_craft'] as List;
    List<TheoryCraft> theoryCraftList =
        theoryCraftFromJson.map((tc) => TheoryCraft.fromJson(tc)).toList();

    return GodRoll(
      combos: comboList,
      masterworks: masterworkList,
      mods: modList,
      socketsDetails: socketList,
      theoryCraft: theoryCraftList,
      weaponHash: json['weaponHash'],
    );
  }
}

import 'dart:math';

import 'package:bungie_api/destiny2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/providers/destinyweaponprovider.dart';

class DestinyProfileProvider with ChangeNotifier {
  DestinyProfileResponse _profile = DestinyProfileResponse();

  DestinyProfileResponse get profile => _profile;

  void setProfile(DestinyProfileResponse newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  Map<int, FullItem> getInstanceDetails(List<DestinyItemComponent> items,
      DestinyWeaponProvider destinyWeaponProvider) {
    Map<int, FullItem> instanceDetails = {};

    for (var item in items) {
      final hash = item.itemHash;
      final itemComponent = profile.itemComponents;
      final instance = itemComponent?.instances?.data?[hash.toString()];
      final perks = itemComponent?.perks?.data?[hash.toString()]?.perks;
      final stats = itemComponent?.stats?.data?[hash.toString()]?.stats;
      final sockets = itemComponent?.sockets?.data?[hash.toString()]?.sockets;
      final manifestData = destinyWeaponProvider.getWeapon(hash!.toString());
      final manifestDataObj = DestinyInventoryItemDefinition.fromJson(
          manifestData as Map<String, dynamic>);

      var fullItem = FullItem(
        item: item,
        instance: instance!,
        perks: perks!,
        stats: stats!,
        sockets: sockets!,
        manifestData: manifestDataObj,
      );

      instanceDetails[int.parse(item.itemInstanceId!)] = fullItem;
    }

    return instanceDetails;
  }

  Map<int, FullItem> getWeaponDetails(List<DestinyItemComponent> items,
      DestinyWeaponProvider destinyWeaponProvider) {
    Map<int, FullItem> instanceDetails = {};

    for (var item in items) {
      final hash = item.itemHash;
      final itemId = item.itemInstanceId;
      final manifestData = destinyWeaponProvider.getWeapon(hash!.toString());

      if (manifestData == null ||
          manifestData['displayProperties'] == null ||
          item.itemInstanceId == null) continue;

      final itemComponent = profile.itemComponents;
      final instance = itemComponent?.instances?.data?[itemId];
      final perks = itemComponent?.perks?.data?[itemId]?.perks;
      final stats = itemComponent?.stats?.data?[itemId]?.stats;
      final sockets = itemComponent?.sockets?.data?[itemId]?.sockets;
      final plugs = itemComponent?.reusablePlugs?.data?[itemId]?.plugs;
      final randomPlugs = itemComponent?.reusablePlugs?.data?[itemId]?.plugs;

      final manifestDataObj = DestinyInventoryItemDefinition.fromJson(
          manifestData as Map<String, dynamic>);

      var fullItem = FullItem(
        item: item,
        instance: instance!,
        perks: perks,
        stats: stats,
        sockets: sockets,
        plugs: plugs,
        randomPlugs: randomPlugs,
        manifestData: manifestDataObj,
      );

      instanceDetails[int.parse(item.itemInstanceId!)] = fullItem;
    }

    return instanceDetails;
  }

  FullItem? getWeaponDetail(
      DestinyItemComponent item, DestinyWeaponProvider destinyWeaponProvider) {
    final hash = item.itemHash;
    final itemId = item.itemInstanceId;
    final manifestData = destinyWeaponProvider.getWeapon(hash!.toString());

    if (manifestData == null ||
        manifestData['displayProperties'] == null ||
        item.itemInstanceId == null) return null;

    final itemComponent = profile.itemComponents;
    final instance = itemComponent?.instances?.data?[itemId];
    final perks = itemComponent?.perks?.data?[itemId]?.perks;
    final stats = itemComponent?.stats?.data?[itemId]?.stats;
    final sockets = itemComponent?.sockets?.data?[itemId]?.sockets;
    final plugs = itemComponent?.reusablePlugs?.data?[itemId]?.plugs;
    final manifestDataObj = DestinyInventoryItemDefinition.fromJson(
        manifestData as Map<String, dynamic>);
    final randomPlugs = itemComponent?.reusablePlugs?.data?[itemId]?.plugs;

    var fullItem = FullItem(
      item: item,
      instance: instance!,
      perks: perks,
      stats: stats,
      sockets: sockets,
      plugs: plugs,
      randomPlugs: randomPlugs,
      manifestData: manifestDataObj,
    );

    return fullItem;
  }
}

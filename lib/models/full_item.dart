import 'package:bungie_api/destiny2.dart';

class FullItem {
  final DestinyItemComponent item;
  final DestinyItemInstanceComponent instance;
  List<DestinyPerkReference>? perks;
  Map<String, DestinyStat>? stats = {};
  List<DestinyItemSocketState>? sockets;
  Map<String, List<DestinyItemPlugBase>>? plugs;
  Map<String, List<DestinyItemPlugBase>>? randomPlugs;

  final DestinyInventoryItemDefinition? manifestData;

  FullItem(
      {required this.item,
      required this.instance,
      this.perks,
      this.stats,
      this.sockets,
      this.plugs,
      this.randomPlugs,
      this.manifestData});
}

import 'package:god_roll_app/helpers/file_helper.dart';
import 'package:god_roll_app/helpers/storage_helper.dart';
import 'package:god_roll_app/services/api_service.dart';
import 'package:god_roll_app/models/enums.dart';

class ManifestHelper {
  static const String _baseUrl = 'https://www.bungie.net';

  static Future<Map<String, Map<String, dynamic>>?>
      fetchWeaponAndPerkJsonIfNeeded() async {
    final storedManifestVersion = await StorageHelper.read('manifestVersion');

    final manifest = await ApiService.getDestinyManifest();
    final currentManifestVersion = manifest.response?.version ?? '';

    if (storedManifestVersion != currentManifestVersion) {
      final manifestJson = await _downloadManifestJson();
      final newWeaponData =
          await _extractWeaponData(manifestJson['inventoryItemJson']);
      final newPerkData =
          await _extractPerkData(manifestJson['inventoryItemJson']);
      final newPlugSetData =
          await _extractPlugSetData(manifestJson['plugSetJson']);

      await StorageHelper.write('manifestVersion', currentManifestVersion);
      return {
        'weapons': newWeaponData,
        'perks': newPerkData,
        'plugSets': newPlugSetData,
      };
    } else {
      final localWeaponData = await FileHelper.readJson('weapon_data.json');
      final localPerkData = await FileHelper.readJson('perk_data.json');
      final localPlugSetData = await FileHelper.readJson('plug_set_data.json');
      return {
        'weapons': localWeaponData!,
        'perks': localPerkData!,
        'plugSets': localPlugSetData!,
      };
    }
  }

  static Future<Map<String, dynamic>> _downloadManifestJson() async {
    final manifestJsonUrls = (await ApiService.getDestinyManifest())
        .response
        ?.jsonWorldComponentContentPaths;
    final inventoryItemUrl =
        manifestJsonUrls!['en']!['DestinyInventoryItemDefinition'];
    final plugSetUrl = manifestJsonUrls['en']!['DestinyPlugSetDefinition'];

    print('Downloading manifest JSON from $inventoryItemUrl');

    final inventoryItemJson =
        await ApiService.fetchJsonFromUrl('$_baseUrl$inventoryItemUrl');
    final plugSetJson =
        await ApiService.fetchJsonFromUrl('$_baseUrl$plugSetUrl');

    return {
      "inventoryItemJson": inventoryItemJson,
      "plugSetJson": plugSetJson,
    };
  }

  static Future<Map<String, dynamic>> _extractWeaponData(
      Map<String, dynamic> manifestJson) async {
    final inventoryWeaponJson = <String, dynamic>{};
    manifestJson.forEach((key, value) {
      if (value['itemType'] == 3) {
        inventoryWeaponJson[key] = value;
      }
    });
    await FileHelper.writeJson('weapon_data.json', inventoryWeaponJson);
    return inventoryWeaponJson;
  }

  static Future<Map<String, dynamic>> _extractPerkData(
      Map<String, dynamic> manifestJson) async {
    List<PlugCategoryHashes> plugCategories = [
      PlugCategoryHashes.Barrels,
      PlugCategoryHashes.Batteries,
      PlugCategoryHashes.Blades,
      PlugCategoryHashes.Bowstrings,
      PlugCategoryHashes.CraftingPlugsWeaponsModsEnhancers,
      PlugCategoryHashes.CraftingPlugsWeaponsModsExtractors,
      PlugCategoryHashes.CraftingPlugsWeaponsModsMemories,
      PlugCategoryHashes.CraftingPlugsWeaponsModsTransfusersLevel,
      PlugCategoryHashes.Frames,
      PlugCategoryHashes.Grips,
      PlugCategoryHashes.Guards,
      PlugCategoryHashes.Hafts,
      PlugCategoryHashes.Intrinsics,
      PlugCategoryHashes.Magazines,
      PlugCategoryHashes.MagazinesGl,
      PlugCategoryHashes.Mods,
      PlugCategoryHashes.Origins,
      PlugCategoryHashes.RandomPerk,
      PlugCategoryHashes.Scopes,
      PlugCategoryHashes.Stocks,
      PlugCategoryHashes.Tubes
    ];

    final hashes = [610365472, 141186804]; // replace with your actual hashes
    const masterworkIdentifier = 'plugs.weapons.masterworks';

    final inventoryPerkJson = <String, dynamic>{};

    for (var entry in manifestJson.entries) {
      List<dynamic>? itemCategoryHashes = entry.value['itemCategoryHashes'];
      final plug = entry.value['plug'];
      if (plug == null) {
        continue;
      }
      int? plugCategoryHash = plug['plugCategoryHash'];
      String? plugCategoryIdentifier = plug['plugCategoryIdentifier'];

      if (plugCategoryHash != null &&
              plugCategories
                  .any((category) => plugCategoryHash == category.value) ||
          itemCategoryHashes != null &&
              itemCategoryHashes.any((hash) => hashes.contains(hash)) ||
          plugCategoryIdentifier != null &&
              plugCategoryIdentifier.contains(masterworkIdentifier)) {
        inventoryPerkJson[entry.key.toString()] = entry.value;
      }
    }

    await FileHelper.writeJson('perk_data.json', inventoryPerkJson);
    return inventoryPerkJson;
  }

  static Future<Map<String, dynamic>> _extractPlugSetData(
      Map<String, dynamic> manifestJson) async {
    final plugSetJson = <String, dynamic>{};

    for (var entry in manifestJson.entries) {
      if (entry.value['plugSet'] != null) {
        plugSetJson[entry.key.toString()] = entry.value;
      }
    }
    await FileHelper.writeJson('plug_set_data.json', plugSetJson);
    return plugSetJson;
  }
}

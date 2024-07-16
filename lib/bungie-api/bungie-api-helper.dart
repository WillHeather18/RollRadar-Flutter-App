import 'dart:io';
import 'dart:convert';
import 'package:bungie_api/core.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/responses/general_user_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ApiConfig {
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  static Future<String?> getLocalApiKey() async {
    return await secureStorage.read(key: 'apiKey');
  }

  static Future<String?> getLocalOauthClientId() async {
    return await secureStorage.read(key: 'oauthClientId');
  }

  static Future<String?> getLocalOauthClientSecret() async {
    return await secureStorage.read(key: 'oauthClientSecret');
  }

  static Future<void> setLocalApiKey(String key) async {
    await secureStorage.write(key: 'apiKey', value: key);
  }

  static Future<void> setLocalOauthClientId(String clientId) async {
    await secureStorage.write(key: 'oauthClientId', value: clientId);
  }

  static Future<void> setLocalOauthClientSecret(String clientSecret) async {
    await secureStorage.write(key: 'oauthClientSecret', value: clientSecret);
  }
}

class Client implements HttpClient {
  static Future<String> getApiKey() async {
    return await ApiConfig.getLocalApiKey() ?? 'no-api-key';
  }

  @override
  Future<HttpResponse> request(HttpClientConfig config,
      {String? accessToken}) async {
    final apiKey = await getApiKey();
    final headers = {'X-API-Key': apiKey};

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final Uri uri =
        Uri.parse(config.url).replace(queryParameters: config.params);
    http.Response response;

    print("Headers: $headers");
    print("URL: ${uri.toString()}");

    if (config.method == 'GET') {
      response = await http.get(uri, headers: headers);
    } else {
      response = await http.post(uri, headers: headers, body: config.body);
    }

    return HttpResponse(response.body, response.statusCode);
  }
}

class BungieApiHelper {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final Client _client = Client();
  static const String _baseUrl = 'https://www.bungie.net/Platform';

  Future<Map<String, Map<String, dynamic>>?>
      fetchWeaponAndPerkJsonIfNeeded() async {
    try {
      //_secureStorage.delete(key: 'manifestVersion'); // For testing purposes
      final storedManifestVersion =
          await _secureStorage.read(key: 'manifestVersion');
      print('Stored manifest version: $storedManifestVersion');

      final manifest = await _getDestinyManifest();
      final currentManifestVersion = manifest.response?.version ?? '';
      print('Current manifest version: $currentManifestVersion');

      if (storedManifestVersion != currentManifestVersion) {
        print('Manifest version has changed. Downloading new data...');
        final manifestJson = await _downloadManifestJson();
        final newWeaponData = await _extractWeaponData(manifestJson);
        final newPerkData = await _extractPerkData(manifestJson);
        final newPlugSetData = await _extractPlugSetData(manifestJson);

        print("Writing new manifest version to storage");
        await _secureStorage.write(
            key: 'manifestVersion', value: currentManifestVersion);

        final confirmedVersion =
            await _secureStorage.read(key: 'manifestVersion');
        print('Confirmed saved manifest version: $confirmedVersion');
        if (confirmedVersion == currentManifestVersion) {
          print('New manifest version has been saved successfully.');
        } else {
          print('Failed to save new manifest version.');
        }
        return {
          'weapons': newWeaponData,
          'perks': newPerkData,
          'plugSets': newPlugSetData
        };
      } else {
        print(
            'Manifest version has not changed. Retrieving weapon/perk/plugSet data locally...');
        final localWeaponData = await _loadLocalWeaponJson();
        final localPerkData = await _loadLocalPerkJson();
        final localPlugSetData = await _loadLocalPlugSetJson();
        return {
          'weapons': localWeaponData!,
          'perks': localPerkData!,
          'plugSets': localPlugSetData!
        };
      }
    } catch (e) {
      print('Error in fetchWeaponAndPerkJsonIfNeeded: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> _downloadManifestJson() async {
    print('Downloading manifest data...');
    final manifestJsonUrls =
        (await _getDestinyManifest()).response?.jsonWorldComponentContentPaths;
    final inventoryItemUrl = _getManifestJsonUrl(
        manifestJsonUrls!, 'en', 'DestinyInventoryItemDefinition');
    final plugSetUrl = _getManifestJsonUrl(
        manifestJsonUrls!, 'en', 'DestinyPlugSetDefinition');

    if (inventoryItemUrl == null || plugSetUrl == null) {
      throw Exception('Failed to get manifest URLs');
    }

    final inventoryItemJson = await _fetchJsonFromUrl(inventoryItemUrl);
    final plugSetJson = await _fetchJsonFromUrl(plugSetUrl);

    await _saveLocalManifestJson(inventoryItemJson, plugSetJson);
    print('Manifest data downloaded and saved.');
    return {...inventoryItemJson, ...plugSetJson};
  }

  static Future<Map<String, dynamic>> _fetchJsonFromUrl(String url) async {
    final fullUrl = Uri.parse(_baseUrl).resolveUri(Uri.parse(url));
    final response = await http.get(fullUrl);

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('JSON decoding error: $e');
        throw Exception('Failed to decode JSON from $fullUrl');
      }
    } else {
      throw Exception('Failed to load JSON from $fullUrl: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> _extractWeaponData(
      Map<String, dynamic> manifestJson) async {
    final inventoryWeaponJson = <String, dynamic>{};

    for (var entry in manifestJson.entries) {
      if (entry.value['itemType'] == 3) {
        inventoryWeaponJson[entry.key.toString()] = entry.value;
      }
    }

    await _saveLocalWeaponJson(inventoryWeaponJson);
    print('Weapon data extracted and saved.');
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
    final masterworkIdentifier = 'plugs.weapons.masterworks';

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

    await _saveLocalPerkJson(inventoryPerkJson);
    print('Perk data extracted and saved.');
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

    await _saveLocalPlugSetJson(plugSetJson);
    print('PlugSet data extracted and saved.');
    return plugSetJson;
  }

  static Future<Map<String, dynamic>?> _loadLocalWeaponJson() async {
    print('Retrieving weapon data from local storage...');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/weapon_data.json';
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        print('Local weapon data retrieved successfully.');
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        print('Local weapon data file does not exist. Downloading data...');
        return await _downloadManifestJson();
      }
    } catch (e) {
      print('Failed to load local weapon data: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _loadLocalPerkJson() async {
    print('Retrieving perk data from local storage...');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/perk_data.json';
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        print('Local perk data retrieved successfully.');
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        print('Local perk data file does not exist. Downloading data...');
        return await _downloadManifestJson();
      }
    } catch (e) {
      print('Failed to load local perk data: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _loadLocalPlugSetJson() async {
    print('Retrieving plug set data from local storage...');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/plug_set_data.json';
      final file = File(path);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        print('Local plug set data retrieved successfully.');
        return json.decode(jsonString) as Map<String, dynamic>;
      } else {
        print('Local plug set data file does not exist. Downloading data...');
        return await _downloadManifestJson();
      }
    } catch (e) {
      print('Failed to load local plug set data: $e');
      return null;
    }
  }

  static Future<void> _saveLocalManifestJson(
      Map<String, dynamic> inventoryItemJson,
      Map<String, dynamic> plugSetJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final manifestPath = '${directory.path}/manifest_data.json';
    final inventoryItemPath = '${directory.path}/weapon_data.json';
    final plugSetPath = '${directory.path}/plug_set_data.json';
    final manifestFile = File(manifestPath);
    final inventoryItemFile = File(inventoryItemPath);
    final plugSetFile = File(plugSetPath);

    try {
      final encodedManifestJson = json.encode(inventoryItemJson);
      final encodedPlugSetJson = json.encode(plugSetJson);
      await manifestFile.writeAsString(encodedManifestJson);
      await inventoryItemFile.writeAsString(encodedManifestJson);
      await plugSetFile.writeAsString(encodedPlugSetJson);
      print('Manifest data saved successfully.');
    } catch (e) {
      print('Failed to save JSON: $e');
    }
  }

  static Future<void> _saveLocalWeaponJson(
      Map<String, dynamic> inventoryWeaponJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/weapon_data.json';
    final file = File(path);
    try {
      final encodedJson = json.encode(inventoryWeaponJson);
      await file.writeAsString(encodedJson);
      print('Weapon data saved successfully.');
    } catch (e) {
      print('Failed to save JSON: $e');
    }
  }

  static Future<void> _saveLocalPerkJson(
      Map<String, dynamic> inventoryPerkJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/perk_data.json';
    final file = File(path);
    try {
      final encodedJson = json.encode(inventoryPerkJson);
      await file.writeAsString(encodedJson);
      print('Perk data saved successfully.');
    } catch (e) {
      print('Failed to save JSON: $e');
    }
  }

  static Future<void> _saveLocalPlugSetJson(
      Map<String, dynamic> plugSetJson) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/plug_set_data.json';
    final file = File(path);
    try {
      final encodedJson = json.encode(plugSetJson);
      await file.writeAsString(encodedJson);
      print('Plug set data saved successfully.');
    } catch (e) {
      print('Failed to save JSON: $e');
    }
  }

  static void _logJsonDetails(Map<String, dynamic> jsonData) {
    print('Logging JSON structure...');
    jsonData.forEach((key, value) {
      print('Key: $key, Type: ${value.runtimeType}');
      if (value is Map) {
        value.forEach((subKey, subValue) {
          print('  SubKey: $subKey, SubType: ${subValue.runtimeType}');
        });
      }
    });
  }

  Future<DestinyProfileResponseResponse> getProfile(
      List<DestinyComponentType> components,
      String destinyMembershipId,
      BungieMembershipType membershipType,
      {String? accessToken}) async {
    final componentsParam =
        components.map((component) => component.value.toString()).join(',');
    final params = {'components': componentsParam};
    final url =
        '$_baseUrl/Destiny2/${membershipType.value}/Profile/$destinyMembershipId/';
    final config = HttpClientConfig('GET', url, params)..bodyContentType = null;

    final response = await _client.request(config, accessToken: accessToken);

    if (response.statusCode == 200) {
      try {
        final jsonBody = json.decode(response.mappedBody);
        return DestinyProfileResponseResponse.asyncFromJson(jsonBody);
      } catch (e) {
        throw Exception('Failed to parse response: ${response.mappedBody}');
      }
    } else {
      throw Exception(
          'Request failed with status: ${response.statusCode}, body: ${response.mappedBody}');
    }
  }

  Future<GeneralUserResponse> getBungieNetUserById(
    String id,
  ) async {
    final Map<String, dynamic> params = <String, dynamic>{};
    final String _id = '$id';
    final HttpClientConfig config = HttpClientConfig(
        'GET', '$_baseUrl/User/GetBungieNetUserById/$_id/', params);
    config.bodyContentType = null;
    final HttpResponse response = await _client.request(config);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.mappedBody);
      return GeneralUserResponse.asyncFromJson(jsonBody);
    }
    throw Exception(response.mappedBody);
  }

  static Future<DestinyManifestResponse> _getDestinyManifest() async {
    final config = HttpClientConfig('GET', '$_baseUrl/Destiny2/Manifest/', {});
    config.bodyContentType = null;
    final response = await _client.request(config);
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.mappedBody);
      return DestinyManifestResponse.asyncFromJson(jsonBody);
    }
    throw Exception(response.mappedBody);
  }

  static String? _getManifestJsonUrl(
      Map<String, Map<String, String>> jsonWorldComponentContentPaths,
      String locale,
      String definitionType) {
    final localeMap = jsonWorldComponentContentPaths[locale];
    if (localeMap == null) {
      print("Locale not found.");
      return null;
    }
    final url = localeMap[definitionType];
    if (url == null) {
      print("Definition type not found.");
    }
    return url;
  }

  BungieMembershipType getMembershipType(int type) {
    switch (type) {
      case 0:
        return BungieMembershipType.None;
      case 1:
        return BungieMembershipType.TigerXbox;
      case 2:
        return BungieMembershipType.TigerPsn;
      case 3:
        return BungieMembershipType.TigerSteam;
      case 4:
        return BungieMembershipType.TigerBlizzard;
      case 5:
        return BungieMembershipType.TigerStadia;
      case 6:
        return BungieMembershipType.TigerEgs;
      case 10:
        return BungieMembershipType.TigerDemon;
      case 254:
        return BungieMembershipType.BungieNext;
      case -1:
        return BungieMembershipType.All;
      default:
        return BungieMembershipType.ProtectedInvalidEnumValue;
    }
  }
}

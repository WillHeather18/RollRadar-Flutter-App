import 'dart:convert';
import 'package:bungie_api/core.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/responses/general_user_response.dart';
import 'package:god_roll_app/services/client.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final Client _client = Client();
  static const String _baseUrl = 'https://www.bungie.net';

  static Future<DestinyManifestResponse> getDestinyManifest() async {
    const url = 'https://getmanifesturl-jwrvpx7udq-uc.a.run.app';
    final response = await _client.request(HttpClientConfig('GET', url, {}));

    if (response.statusCode == 200) {
      return DestinyManifestResponse.asyncFromJson(
          json.decode(response.mappedBody));
    } else {
      throw Exception('Failed to load Destiny manifest ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchJsonFromUrl(String url) async {
    final response = await _client.request(HttpClientConfig('GET', url, {}));

    if (response.statusCode == 200) {
      try {
        return json.decode(response.mappedBody);
      } catch (e) {
        throw Exception('Failed to decode JSON from $url');
      }
    } else {
      throw Exception('Failed to load JSON from $url: ${response.mappedBody}');
    }
  }

  Future<GeneralUserResponse> getBungieNetUserById(String id) async {
    final url = '$_baseUrl/Platform/User/GetBungieNetUserById/$id/';
    final response = await _client.request(HttpClientConfig('GET', url, {}));

    if (response.statusCode == 200) {
      return GeneralUserResponse.asyncFromJson(
          json.decode(response.mappedBody));
    } else {
      throw Exception(
          'Failed to load Bungie.net user by ID ${response.statusCode}');
    }
  }

  Future<DestinyProfileResponseResponse> getProfile(
    List<DestinyComponentType> components,
    String destinyMembershipId,
    BungieMembershipType membershipType, {
    String? accessToken,
  }) async {
    final componentsParam = components.map((c) => c.value.toString()).join(',');
    final params = {'components': componentsParam};
    final url =
        '$_baseUrl/Platform/Destiny2/${membershipType.value}/Profile/$destinyMembershipId/';
    final response = await _client.request(
      HttpClientConfig('GET', url, params),
      accessToken: accessToken,
    );

    if (response.statusCode == 200) {
      return DestinyProfileResponseResponse.asyncFromJson(
          json.decode(response.mappedBody));
    } else {
      throw Exception('Failed to load Destiny profile');
    }
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

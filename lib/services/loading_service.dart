import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/responses/general_user_response.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/helpers/manifest_helper.dart';
import 'package:god_roll_app/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:god_roll_app/tools/compute_isolate.dart';
import 'package:provider/provider.dart';
import 'package:god_roll_app/providers/destinycharacterprovider.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:god_roll_app/providers/destinyweaponprovider.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import 'package:god_roll_app/providers/userprovider.dart';

class LoadingService {
  final BuildContext context;

  LoadingService(this.context);

  static Future<Map<String, Map<String, dynamic>>?>
      fetchWeaponAndPerkJsonIfNeededWrapperCompute() async {
    return await ManifestHelper.fetchWeaponAndPerkJsonIfNeeded();
  }

  Future<void> initializeApp({
    required String bungieId,
    required String membershipType,
    required String destinyMembershipId,
    required String accessToken,
    required Function(String) setLoadingMessage,
    required Function(bool) setIsLoading,
    required Function(
            Map<String, dynamic>?, Map<String, dynamic>?, Map<String, dynamic>?)
        updateData,
  }) async {
    final startTime = DateTime.now();
    await requestNotificationPermissions();

    setLoadingMessage('Downloading latest Destiny 2 data...');
    ApiService apiService = ApiService();

    final data =
        await computeIsolate(fetchWeaponAndPerkJsonIfNeededWrapperCompute);

    final inventoryWeaponJson = data?['weapons'];
    final inventoryPerkJson = data?['perks'];
    final plugSets = data?['plugSets'];

    setLoadingMessage('Fetching profile...');

    List<DestinyComponentType> components = [
      DestinyComponentType.Profiles,
      DestinyComponentType.Characters,
      DestinyComponentType.CharacterEquipment,
      DestinyComponentType.CharacterInventories,
      DestinyComponentType.ProfileInventories,
      DestinyComponentType.ItemInstances,
      DestinyComponentType.ItemPerks,
      DestinyComponentType.ItemStats,
      DestinyComponentType.ItemSockets,
      DestinyComponentType.ItemReusablePlugs
    ];

    try {
      GeneralUserResponse? userResponse =
          await apiService.getBungieNetUserById(bungieId);
      GeneralUser user = userResponse.response!;

      DestinyProfileResponseResponse profileResponse =
          await apiService.getProfile(
        components,
        destinyMembershipId,
        apiService.getMembershipType(int.parse(membershipType)),
        accessToken: accessToken,
      );

      Map<String, DestinyCharacterComponent> characters =
          profileResponse.response?.characters?.data ?? {};
      DestinyProfileResponse? profile = profileResponse.response;

      updateProviders(characters, profile!, inventoryWeaponJson!,
          inventoryPerkJson!, user, bungieId, plugSets!);

      setLoadingMessage('Data Loaded');
      setIsLoading(false);

      final endTime = DateTime.now();
      final loadingTime = endTime.difference(startTime);
      print("Total loading time: ${loadingTime.inSeconds} seconds");
    } catch (e) {
      setLoadingMessage('Failed to load data');
      setIsLoading(false);
      print("Failed to fetch profile: $e");
    }
  }

  void updateProviders(
      Map<String, DestinyCharacterComponent> characters,
      DestinyProfileResponse profile,
      Map<String, dynamic> inventoryWeaponJson,
      Map<String, dynamic> perks,
      GeneralUser user,
      String bungieId,
      Map<String, dynamic> plugSets) {
    final perkProvider =
        Provider.of<DestinyPerkProvider>(context, listen: false);
    final characterProvider =
        Provider.of<DestinyCharacterProvider>(context, listen: false);
    final destinyProfileProvider =
        Provider.of<DestinyProfileProvider>(context, listen: false);
    final destinyWeaponProvider =
        Provider.of<DestinyWeaponProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    perkProvider.setPerks(perks);
    perkProvider.setPlugSets(plugSets);
    characterProvider.setCharacters(characters);
    destinyProfileProvider.setProfile(profile);
    destinyWeaponProvider.setWeapons(inventoryWeaponJson);
    userProvider.setUser(user);
    userProvider.setBungieId(bungieId);
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }
}

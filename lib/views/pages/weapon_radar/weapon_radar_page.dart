import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:god_roll_app/providers/destinyweaponprovider.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import 'package:god_roll_app/views/pages/weapon_radar/widgets/weapon_list_item.dart';
import 'package:god_roll_app/views/widgets/app_drawer.dart';
import 'package:god_roll_app/views/widgets/banner_ad.dart';
import 'package:god_roll_app/views/widgets/radar_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:god_roll_app/services/firestore_listener.dart';

class WeaponRadar extends StatefulWidget {
  final String bungieID;

  const WeaponRadar({Key? key, required this.bungieID}) : super(key: key);

  @override
  _WeaponRadarState createState() => _WeaponRadarState();
}

class _WeaponRadarState extends State<WeaponRadar>
    with SingleTickerProviderStateMixin {
  List<dynamic> _latestWeapons = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    BannerAdWidget.initBannerAd();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCirc);

    // Initialize Firestore listener
    FirestoreListener(
      bungieID: widget.bungieID,
      onWeaponsUpdated: (weapons) {
        setState(() {
          _latestWeapons = weapons;
        });
      },
    ).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<DestinyProfileProvider>(context);
    final profile = profileProvider.profile;
    final destinyWeaponsProvider =
        Provider.of<DestinyWeaponProvider>(context, listen: false);
    final destinyPerkProvider = Provider.of<DestinyPerkProvider>(context);

    final profileInventory = profile.profileInventory!.data!.items!;
    final characterEquipment = profile.characterEquipment?.data?.values
            .expand((e) => e.items!)
            .toList() ??
        [];
    final characterInventories = profile.characterInventories?.data?.values
        .expand((inventory) => inventory.items ?? [])
        .toList();
    List<DestinyItemComponent> allWeapons = [
      ...profileInventory,
      ...characterEquipment,
      ...characterInventories!
    ];

    print("latest weapons length ${_latestWeapons.length}");

    var weaponDetails =
        profileProvider.getWeaponDetails(allWeapons, destinyWeaponsProvider);

    // First, filter and convert to List to sort
    var filteredWeapons = weaponDetails.values
        .where((weapon) => _latestWeapons.contains(weapon.item.itemInstanceId))
        .toList();

    // Sort by itemInstanceId in descending order
    filteredWeapons.sort((a, b) => int.parse(b.item.itemInstanceId!)
        .compareTo(int.parse(a.item.itemInstanceId!)));

    // Then take the top 20
    var latestWeaponDetails = filteredWeapons.take(20).toList();

    print("latest weapon details length ${latestWeaponDetails.length}");

    return Scaffold(
      backgroundColor: const Color(0xFF282c34),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0f0f23),
        title: Text(
          'Weapon Radar',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SvgPicture.asset(
              'assets/icons/radar_logo.svg',
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const RadarSweep(
              imageUrl:
                  'https://user-images.githubusercontent.com/58719230/218909229-67867fec-6f4a-43fb-bfc3-33d6bc42ae2e.png'),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ListView.builder(
                itemCount: latestWeaponDetails.length,
                padding: EdgeInsets.only(bottom: BannerAdWidget.bannerAdHeight),
                itemBuilder: (context, index) {
                  final weapon = latestWeaponDetails[index];

                  final weaponSocketHashes = weapon.sockets;

                  List<DestinyInventoryItemDefinition?> mainPerkDetails = [
                    1,
                    2,
                    3,
                    4
                  ]
                      .map((index) => destinyPerkProvider.getPerk(
                          weaponSocketHashes![index].plugHash.toString()))
                      .toList();

                  return WeaponListItem(
                    weapon: weapon,
                    mainPerkDetails: mainPerkDetails,
                  );
                },
              ),
            ),
          ),
          if (BannerAdWidget.bannerAd != null)
            const Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdWidget(),
            ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }
}

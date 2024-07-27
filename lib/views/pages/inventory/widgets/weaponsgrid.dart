import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/providers/destinyweaponprovider.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import 'package:god_roll_app/views/pages/detail_page/detail_page.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/custombottomsheet.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/item_icon.dart';
import 'package:provider/provider.dart';

class WeaponWidget extends StatefulWidget {
  final ValueNotifier<int> characterIdNotifier;
  final double adHeight;
  final VoidCallback onRefresh;
  final bool isVault = false;

  const WeaponWidget(
      {super.key,
      this.adHeight = 0,
      required this.onRefresh,
      required this.characterIdNotifier});

  @override
  _WeaponWidgetState createState() => _WeaponWidgetState();
}

class _WeaponWidgetState extends State<WeaponWidget> {
  List<FullItem> _primaryWeapons = [];
  List<FullItem> _secondaryWeapons = [];
  List<FullItem> _powerWeapons = [];

  @override
  void initState() {
    super.initState();
    // Calling organizeWeapons directly` to ensure weapons are organized on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.characterIdNotifier.addListener(organizeWeapons);
      organizeWeapons();
    });
  }

  @override
  void dispose() {
    widget.characterIdNotifier.removeListener(organizeWeapons);
    super.dispose();
  }

  void organizeWeapons() {
    final profileProvider =
        Provider.of<DestinyProfileProvider>(context, listen: false);
    final profile = profileProvider.profile;
    final destinyWeaponsProvider =
        Provider.of<DestinyWeaponProvider>(context, listen: false);

    List<DestinyItemComponent> allWeapons = [];
    if (widget.characterIdNotifier.value == 0) {
      allWeapons = profile.profileInventory!.data!.items!;
    } else {
      final characterEquipment = profile.characterEquipment
          ?.data?[widget.characterIdNotifier.value.toString()]?.items;
      final characterWeapons = profile.characterInventories
          ?.data?[widget.characterIdNotifier.value.toString()]?.items;

      allWeapons = [...characterEquipment!, ...characterWeapons!];
    }

    final fullWeapons =
        profileProvider.getWeaponDetails(allWeapons, destinyWeaponsProvider);

    setState(() {
      _primaryWeapons = fullWeapons.values.where((weapon) {
        return weapon.manifestData!.inventory?.bucketTypeHash == 1498876634;
      }).toList();

      _secondaryWeapons = fullWeapons.values.where((weapon) {
        return weapon.manifestData!.inventory?.bucketTypeHash == 2465295065;
      }).toList();

      _powerWeapons = fullWeapons.values.where((weapon) {
        return weapon.manifestData!.inventory?.bucketTypeHash == 953998645;
      }).toList();
    });
  }

  SliverGrid _createWeaponSlotGrid(List<FullItem> weapons) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var weapon = weapons[index];

          double totalPercentage = 0;

          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                CustomBottomSheetRoute(
                  child: DetailPage(weapon: weapon),
                ),
              );
            },
            child: Transform.scale(
              scale: weapon.instance.isEquipped! ? 1.2 : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: weapon.item.itemInstanceId!,
                    child: WeaponIcon(
                        weaponInstance: weapon,
                        weaponManifest: weapon.manifestData!,
                        showDetails: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Stack(
                      alignment: Alignment
                          .center, // Center the text over the progress bar
                      children: [
                        SizedBox(
                          height: 15,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: LinearProgressIndicator(
                            value: totalPercentage / 100,
                            color: _getProgressColor(totalPercentage),
                            backgroundColor: const Color(0xFF282c34),
                          ),
                        ),
                        Text("${totalPercentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
        childCount: weapons.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1 / 1.5,
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) {
      return Color(0xFFd4af37); // Gold
    } else if (percentage >= 50) {
      return Color(0xFF9b30ff); // Purple
    } else if (percentage >= 25) {
      return Color(0xFF007fff); // Blue
    } else {
      return Color(0xFF3cb371); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    organizeWeapons();

    return RefreshIndicator(
      onRefresh: () async {},
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: CustomScrollView(
          slivers: <Widget>[
            if (_primaryWeapons.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Kinetic',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _createWeaponSlotGrid(_primaryWeapons),
            ],
            if (_secondaryWeapons.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Energy',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _createWeaponSlotGrid(_secondaryWeapons),
            ],
            if (_powerWeapons.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Power',
                    style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _createWeaponSlotGrid(_powerWeapons),
            ],
            SliverToBoxAdapter(
              child: SizedBox(
                height: widget.adHeight,
              ),
            )
          ],
        ),
      ),
    );
  }
}

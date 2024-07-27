// ignore_for_file: unnecessary_null_comparison

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/services/god-roll-service.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PerksPanel extends StatefulWidget {
  const PerksPanel({
    Key? key,
    required this.weapon,
    this.godroll,
  }) : super(key: key);

  final FullItem weapon;
  final Map<String, dynamic>? godroll;

  @override
  State<PerksPanel> createState() => _PerksPanelState();
}

class _PerksPanelState extends State<PerksPanel> {
  int? selectedPerkIndex;
  bool showIntrinsicPerkDescription = true;
  bool showModDescription = true;
  bool showMasterworkDescription = false;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GodRollService godRollService = GodRollService();
    final destinyPerkProvider = Provider.of<DestinyPerkProvider>(context);
    final displaySource = widget.weapon.manifestData!.displaySource;

    final weaponSocketHashes = widget.weapon.sockets;
    final allPerkOptions = destinyPerkProvider.getAllWeaponPerks(widget.weapon);
    var instrinicPerk =
        destinyPerkProvider.getPerk(weaponSocketHashes![0].plugHash.toString());

    var modDetails =
        destinyPerkProvider.getPerk(weaponSocketHashes[6].plugHash.toString());

    var masterworkDetails =
        destinyPerkProvider.getPerk(weaponSocketHashes[7].plugHash.toString());

    var extraPerkDetail =
        destinyPerkProvider.getPerk(weaponSocketHashes[8].plugHash.toString());

    List<DestinyInventoryItemDefinition?> mainPerkDetails = [1, 2, 3, 4]
        .map((index) => destinyPerkProvider
            .getPerk(weaponSocketHashes[index].plugHash.toString()))
        .toList();

    return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFda3e52),
            secondary: Color(0xFFf0c330),
          ),
          dividerColor: Colors.grey[700],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displaySource != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Text(
                  displaySource,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Intrinsic Trait:',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Container(
                height: 60,
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.network(
                    "https://www.bungie.net${instrinicPerk?.displayProperties?.icon}",
                  ),
                ),
              ),
              title: Text(
                instrinicPerk?.displayProperties?.name ?? 'Intrinsic Perk',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                setState(() {
                  showIntrinsicPerkDescription =
                      !showIntrinsicPerkDescription; // Step 2: Toggle description visibility
                });
              },
            ),
            if (showIntrinsicPerkDescription) // Step 3: Conditionally display the description
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Text(
                  instrinicPerk?.displayProperties?.description ?? 'N/A',
                  style: GoogleFonts.lato(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Weapon Perks:',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            ListView.separated(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allPerkOptions
                  .length, // Add 1 to itemCount if extraPerkDetail exists
              itemBuilder: (context, index) {
                List<DestinyInventoryItemDefinition>? perkSlot =
                    allPerkOptions[index];

                // Find the active perk and move it to the first position
                DestinyInventoryItemDefinition? activePerk;
                for (var perk in perkSlot) {
                  if (perk.hash == mainPerkDetails[index]?.hash) {
                    activePerk = perk;
                    break;
                  }
                }
                if (activePerk != null) {
                  perkSlot.remove(activePerk);
                  perkSlot.insert(0, activePerk);
                }

                bool isActiveGodRoll = false;
                if (widget.godroll != null) {
                  isActiveGodRoll = godRollService.isPerkGodRoll(
                      widget.godroll!,
                      activePerk?.hash ?? 0,
                      activePerk!.displayProperties!.name!,
                      index);
                }

                final decodedDescription = activePerk
                    ?.displayProperties?.description
                    ?.replaceAll('â¢', '•');

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active perk and details
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (activePerk != null) ...[
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: !isActiveGodRoll
                                    ? Colors.lightBlue
                                    : Colors.yellow[800],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.network(
                                  "https://www.bungie.net${activePerk.displayProperties?.icon}",
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activePerk.displayProperties?.name ??
                                        'Perk',
                                    style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      decodedDescription ?? 'N/A',
                                      style: GoogleFonts.lato(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Inactive perks
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: perkSlot
                          .where((perk) =>
                              perk.hash != mainPerkDetails[index]?.hash)
                          .map((perk) {
                        return Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(left: 8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.network(
                              "https://www.bungie.net${perk.displayProperties?.icon}",
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) =>
                  SizedBox(height: 10), // Gap between items
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('Weapon Mods:',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Container(
                height: 60,
                width: 60,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.network(
                    "https://www.bungie.net${modDetails?.displayProperties?.icon}",
                  ),
                ),
              ),
              title: Text(
                modDetails?.displayProperties?.name ?? 'Mod',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (masterworkDetails != null &&
                masterworkDetails.displayProperties!.hasIcon! == true)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('Masterwork:',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                    )),
              ),
            if (masterworkDetails != null &&
                masterworkDetails.displayProperties!.hasIcon! == true)
              ListTile(
                leading: Container(
                  height: 60,
                  width: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.network(
                      "https://www.bungie.net${masterworkDetails.displayProperties?.icon}",
                    ),
                  ),
                ),
                title: Text(
                  masterworkDetails.displayProperties?.name ?? 'Masterwork',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            )
          ],
        ));
  }
}

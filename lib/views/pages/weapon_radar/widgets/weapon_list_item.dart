import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:god_roll_app/views/widgets/item_icon.dart';
import 'package:god_roll_app/views/pages/detail_page/detail_page.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/custombottomsheet.dart';
import 'package:god_roll_app/models/full_item.dart';

class WeaponListItem extends StatelessWidget {
  final FullItem weapon;
  final List<DestinyInventoryItemDefinition?> mainPerkDetails;

  const WeaponListItem({
    Key? key,
    required this.weapon,
    required this.mainPerkDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weaponName =
        weapon.manifestData!.displayProperties!.name ?? "Unknown";

    return SizedBox(
      height: 100,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            CustomBottomSheetRoute(
              child: DetailPage(
                weapon: weapon,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Weapon icon
              Column(
                children: [
                  SizedBox(
                    height: 75,
                    width: 75,
                    child: Hero(
                      tag: weapon.item.itemInstanceId!,
                      child: WeaponIcon(
                        weaponInstance: weapon,
                        showDetails: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  width: 10), // Add some space between weapon icon and perks
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    weaponName,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(
                      height:
                          5), // Add some space between weapon name and perks
                  Wrap(
                    spacing: 4.0,
                    children:
                        List<Widget>.generate(mainPerkDetails.length, (index) {
                      var perk = mainPerkDetails[index];
                      if (perk != null && perk.displayProperties != null) {
                        return Image.network(
                          "https://www.bungie.net${perk.displayProperties?.icon ?? ''}",
                          width: 40, // Adjust size as needed
                          height: 40, // Adjust size as needed
                        );
                      } else {
                        return Container(); // Or some placeholder widget
                      }
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

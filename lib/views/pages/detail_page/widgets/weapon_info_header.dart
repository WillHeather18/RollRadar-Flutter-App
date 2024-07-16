import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/views/widgets/item_icon.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:god_roll_app/tools/lookup.dart';

class WeaponInfoHeader extends StatelessWidget {
  final FullItem weapon;

  const WeaponInfoHeader({Key? key, required this.weapon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weaponName =
        weapon.manifestData?.displayProperties?.name ?? 'Unknown';
    final weaponType = weapon.manifestData?.itemTypeDisplayName ?? 'Unknown';
    final weaponTier =
        weapon.manifestData?.inventory?.tierTypeName ?? 'Unknown';

    final ammoType =
        getAmmoType(weapon.manifestData!.equippingBlock!.ammoType!);
    final damageTypeIcon =
        getDamageIcon(weapon.manifestData!.defaultDamageType!);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: const Color.fromRGBO(103, 58, 183, 1).withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 85,
              child: Hero(
                tag: weapon.item.itemInstanceId!,
                child: WeaponIcon(
                  weaponManifest: weapon.manifestData!,
                  weaponInstance: weapon,
                  showDetails: false,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weaponName,
                      style: GoogleFonts.lato(
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 25,
                          width: 25,
                          child: SvgPicture.asset(
                            ammoType == 'Primary'
                                ? 'assets/icons/ammo-primary.svg'
                                : ammoType == 'Special'
                                    ? 'assets/icons/ammo-special.svg'
                                    : 'assets/icons/ammo-heavy.svg',
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AutoSizeText(
                              '$weaponTier $weaponType',
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              minFontSize: 12,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Image.network(
                      'https://www.bungie.net$damageTypeIcon',
                    ),
                  ),
                  Text(
                    "${weapon.instance.primaryStat?.value}",
                    style: GoogleFonts.lato(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import 'package:god_roll_app/tools/lookup.dart';

import 'package:google_fonts/google_fonts.dart';

class WeaponIcon extends StatelessWidget {
  final FullItem? weaponInstance;
  final DestinyInventoryItemDefinition? weaponManifest;
  final bool showDetails;

  const WeaponIcon({
    super.key,
    this.weaponInstance,
    this.weaponManifest,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Null check for destinyWeapon since it's required and should not be null
    final iconPath = weaponManifest?.displayProperties?.icon ??
        weaponInstance?.manifestData?.displayProperties?.icon;
    final watermarkPath = weaponManifest?.iconWatermark ??
        weaponInstance?.manifestData?.iconWatermark;
    final damageType = weaponManifest?.defaultDamageType ??
        weaponInstance?.manifestData?.defaultDamageType;
    bool isMasterwork =
        (weaponInstance?.item.state!.value ?? 0) & (1 << 2) != 0;
    final primaryStatValue = weaponInstance?.instance.primaryStat?.value;
    String damageTypeIcon = getDamageIcon(damageType!);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: isMasterwork ? Colors.yellow[700]! : Colors.white,
              width: isMasterwork ? 3 : 2),
          gradient: isMasterwork
              ? RadialGradient(
                  colors: [Colors.yellow, Colors.orange.shade800],
                  center: Alignment.center,
                  radius: 0.5,
                  stops: const [0.4, 1.0],
                )
              : null,
          boxShadow: isMasterwork
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 0), // center glow effect
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(3, 3), // changes position of shadow
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (iconPath != null)
              Image.network(
                'https://www.bungie.net$iconPath',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const Center(
                      child: const CircularProgressIndicator(),
                    );
                  }
                },
              )
            else
              const Center(
                child: Text(
                  'No Icon Available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (watermarkPath != null)
              Image.network(
                'https://www.bungie.net$watermarkPath',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Row(
                    children: [
                      if (damageType != null)
                        Image.network(
                          'https://www.bungie.net$damageTypeIcon',
                          height: 12,
                          width: 12,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const SizedBox(
                                height: 12,
                                width: 12,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 1),
                                ),
                              );
                            }
                          },
                        ),
                      const SizedBox(width: 2),
                      if (showDetails && primaryStatValue != null)
                        Text(
                          primaryStatValue.toString(),
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

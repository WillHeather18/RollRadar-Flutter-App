import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeaponIcon extends StatelessWidget {
  final Map<String, dynamic>? weapon;
  final Map<String, dynamic> associatedWeaponDetails;
  final bool showDetails;

  const WeaponIcon({
    super.key,
    this.weapon,
    required this.associatedWeaponDetails,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    // Null check for associatedWeaponDetails since it's required and should not be null
    final iconPath = associatedWeaponDetails['iconPath'] as String?;
    final watermarkPath = associatedWeaponDetails['watermarkPath'] as String?;
    final damageTypes =
        associatedWeaponDetails['damageTypes'] as List<dynamic>?;

    final List<int> masterworkHashes = [
      2357520979,
      2674077375,
      2697220197,
      2942552113,
      2993547493,
      3128594062,
      3444329767,
      3486498337,
      3557020689,
      3689550782,
      3803457565,
      178753455,
      186337601,
      266016299,
      384158423,
      654849177,
      684616255,
      758092021,
      915325363,
      1154004463,
      1431498388,
      1639384016
    ];

    bool isMasterwork = false;

    // Extracting primaryStat value safely
    final primaryStatValue =
        weapon?['instance']?['primaryStat']?['value'] as int?;

    if (showDetails == true) {
      for (var socketDetail in weapon?['socketsDetails']) {
        for (var masterworkHash in masterworkHashes) {
          if (socketDetail['plugHash'] == masterworkHash) {
            isMasterwork = true;
            break;
          }
        }
      }
    }

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
                  stops: [0.4, 1.0],
                )
              : null,
          boxShadow: isMasterwork
              ? [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 0), // center glow effect
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(3, 3), // changes position of shadow
                  ),
                ],
        ),
        child: Stack(
          children: [
            if (iconPath != null)
              Image.network(
                'https://www.bungie.net$iconPath',
                fit: BoxFit.cover,
              ),
            if (watermarkPath != null)
              Image.network(
                'https://www.bungie.net$watermarkPath',
                fit: BoxFit.cover,
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: Row(
                    children: [
                      if (damageTypes != null && damageTypes.length > 1)
                        Image.network(
                          'https://www.bungie.net${damageTypes[1]}',
                          height: 12,
                          width: 12,
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

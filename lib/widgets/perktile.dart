import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/perkdetailsprovider.dart';

class PerksPanel extends StatelessWidget {
  const PerksPanel({Key? key, required this.weapon, required this.godrolls})
      : super(key: key);

  final Map<String, dynamic> weapon;
  final List<dynamic> godrolls;

  @override
  Widget build(BuildContext context) {
    final perkDetailsProvider = Provider.of<PerkDetailsProvider>(context);
    final perkDetailsList = perkDetailsProvider.perkDetails;

    final godroll = godrolls.firstWhere(
      (godroll) => godroll['weaponHash'] == weapon['weaponHash'],
      orElse: () => <String, dynamic>{},
    );

    final List<dynamic> weaponSocketHashes = weapon['socketHashes'];

    List<dynamic> orderedPerkDetails = [];
    for (var socketHash in weaponSocketHashes) {
      var perkDetail = perkDetailsList.firstWhere(
        (perkDetail) => perkDetail['hash'] == socketHash,
        orElse: () => null,
      );
      if (perkDetail != null) {
        orderedPerkDetails.add(perkDetail);
      }
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFda3e52), // Adjust to fit your app's theme
          secondary: Color(0xFFf0c330),
        ),
        dividerColor: Colors.grey[700],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: const Color(0xFF1f2233),
        title: Text(
          "Perks",
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
        ),
        children: <Widget>[
          const SizedBox(height: 10),
          SingleChildScrollView(
            child: Column(
              children: orderedPerkDetails.map((perkDetail) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        "https://www.bungie.net${perkDetail['displayProperties']['icon']}",
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perkDetail['displayProperties']['name'],
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              perkDetail['displayProperties']['description'],
                              style: GoogleFonts.lato(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

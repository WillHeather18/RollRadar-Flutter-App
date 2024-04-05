import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../providers/weapondetailsprovider.dart';
import '../providers/godrollsprovider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/starrating.dart';
import '../widgets/statspanel.dart';
import '../widgets/perktile.dart';
import '../widgets/godrollpanel.dart';

class DetailPage extends StatefulWidget {
  final dynamic weapon;

  DetailPage({required this.weapon});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // iOS
    ));
    var weaponDetailsProvider = Provider.of<WeaponDetailsProvider>(context);
    var godRollsProvider = Provider.of<GodRollsProvider>(context);
    var weaponDetailsList = weaponDetailsProvider.weaponDetails;
    var godRollsList = godRollsProvider.godRolls;
    var weaponDetails = weaponDetailsList.firstWhere(
      (element) => element['id'] == widget.weapon['weaponHash'],
      orElse: () => <String, dynamic>{},
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0f0f23),
        title: Text(
          '${widget.weapon['weaponName']}',
          style: GoogleFonts.orbitron(
            textStyle: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0f0f23), Color(0xFF282c34)],
              ),
            ),
            height: double.infinity, // Ensures it fills the vertical space
            width: double.infinity, // Ensures it fills the horizontal space
          ),
          // Your existing scrollable content on top of the gradient background
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Adjusted to min for the Column inside SingleChildScrollView
              children: <Widget>[
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${weaponDetails['rarity']} ${weaponDetails['type']}',
                    style: GoogleFonts.orbitron(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                ),
                const SizedBox(height: 10),
                StarRating(fraction: widget.weapon['score'].toString()),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.network(
                        'https://www.bungie.net${weaponDetails['damageTypes'][1]}',
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                        "${widget.weapon['instance']['primaryStat']['value']} Attack",
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 28),
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: SvgPicture.asset(
                        '${weaponDetails['ammoType'] == 'Primary' ? 'assets/icons/ammo-primary.svg' : weaponDetails['ammoType'] == 'Special' ? 'assets/icons/ammo-special.svg' : 'assets/icons/ammo-heavy.svg'}',
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xFF282c34),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        'https://www.bungie.net${weaponDetails['screenshotPath']}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    weaponDetails['acquisitionSource'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                PerksPanel(weapon: widget.weapon, godrolls: godRollsList),
                const SizedBox(height: 10),
                GodRollPanel(weapon: widget.weapon, godrolls: godRollsList),
                const SizedBox(height: 10),
                StatsPanel(weaponDetails: weaponDetails, weapon: widget.weapon),
                // Make sure there's a SizedBox at the end to ensure scrolling capability if the content is shorter than the screen height
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

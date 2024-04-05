import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Ensure this package is imported.

class StatsPanel extends StatelessWidget {
  final Map<String, dynamic> weaponDetails;
  final Map<String, dynamic> weapon;
  final List<String> nonProgressBarStats = [
    "4284893193",
    "3871231066",
    "2715839340"
  ];
  final List<String> orderedStatNames = [
    "Impact",
    "Range",
    "Stability",
    "Handling",
    "Reload Speed",
    "Aim Assistance",
    "Zoom",
    "Airborne Effectiveness",
    "Rounds Per Minute",
    "Magazine",
    "Recoil Direction"
  ];

  StatsPanel({Key? key, required this.weaponDetails, required this.weapon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> stats = List.from(weaponDetails['stats']);

    // Sort stats according to orderedStatNames, pushing unlisted stats to the end.
    stats.sort((a, b) {
      int indexA = orderedStatNames.indexOf(a['stat_name']);
      int indexB = orderedStatNames.indexOf(b['stat_name']);
      indexA = indexA == -1 ? orderedStatNames.length : indexA;
      indexB = indexB == -1 ? orderedStatNames.length : indexB;
      return indexA.compareTo(indexB);
    });

    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFda3e52),
          secondary: Color(0xFFf0c330),
        ),
      ),
      child: ExpansionTile(
        backgroundColor: const Color(0xFF1f2233),
        title: Text(
          "Weapon Stats",
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
        ),
        children: stats.map<Widget>((stat) {
          String statHash = stat['stat_hash'].toString();
          var statValue =
              weapon['statDetails']['stats'][statHash]?['value']?.toDouble();
          var statBaseValue = stat['value']?.toDouble();
          if (statValue == null) {
            return const SizedBox
                .shrink(); // Skip stats with null or non-numeric values.
          }

          bool isNonProgressBarStat = nonProgressBarStats.contains(statHash);

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: AutoSizeText(
                        stat['stat_name'],
                        style: TextStyle(color: Colors.grey[400]),
                        maxLines: 1,
                        minFontSize: 10,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Spacing between name and bar/value
                    if (!isNonProgressBarStat)
                      Expanded(
                        flex: 9, // Adjusted for progress bar space
                        child: SizedBox(
                          height: 15, // Height of the progress bar
                          child: Stack(
                            children: <Widget>[
                              // Base stat progress bar (white)

                              // Current stat progress bar (yellow)
                              SizedBox(
                                height: 10,
                                child: LinearProgressIndicator(
                                  value: statValue / 100,
                                  backgroundColor: Colors
                                      .transparent, // Make bg transparent to show the white bar beneath
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.yellow),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                                child: LinearProgressIndicator(
                                  value: statBaseValue / 100,
                                  backgroundColor: Colors.transparent,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!isNonProgressBarStat)
                      const SizedBox(
                          width: 10), // Spacing between bar and value
                    if (!isNonProgressBarStat) // This line ensures the value is only shown for progress bar stats
                      Expanded(
                        flex:
                            2, // Separate flex value for progress bar value spacing
                        child: Text(
                          '${statValue.toInt()}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    if (isNonProgressBarStat)
                      Expanded(
                        flex:
                            11, // Ensures consistent alignment with progress bar values
                        child: Text(
                          '${statValue.toInt()}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10), // Spacing between rows
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

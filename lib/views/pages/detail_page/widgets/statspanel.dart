import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/tools/lookup.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Ensure this package is imported.

class StatsPanel extends StatelessWidget {
  final FullItem weapon;
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

  StatsPanel({Key? key, required this.weapon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, DestinyStat> stats = weapon.stats!;

    List<dynamic> detailedStats = stats.values.map((value) {
      return {
        'stat_name': statNameLookup(value.statHash!),
        'value': value.value,
        'stat_hash': value.statHash
      };
    }).toList();

    // Sort stats according to orderedStatNames, pushing unlisted stats to the end.
    detailedStats.sort((a, b) {
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
      child: Column(
        children: detailedStats.map<Widget>((stat) {
          String statHash = stat['stat_hash'].toString();
          var statValue = weapon.stats![statHash]?.value?.toDouble() ?? 0.0;
          var statBaseValue =
              weapon.manifestData!.stats!.stats![statHash]?.value?.toDouble() ??
                  0.0;

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
                ), // Spacing between rows
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

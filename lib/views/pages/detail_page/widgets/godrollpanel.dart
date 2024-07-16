import 'dart:convert'; // Add this import
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/providers/profileprovider.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class GodRollPanel extends StatefulWidget {
  final FullItem weapon;
  final dynamic godroll;

  const GodRollPanel(
      {Key? key, required this.weapon, required this.godroll}) // Add this line
      : super(key: key);

  @override
  _GodRollPanelState createState() => _GodRollPanelState();
}

class _GodRollPanelState extends State<GodRollPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int percentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0 / 100).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward(); //

    _calculatePercentage();
  }

  Future<void> _calculatePercentage() async {
    int calculatedPercentage = 1;
    setState(() {
      percentage = calculatedPercentage;
      _animation = Tween<double>(begin: 0, end: calculatedPercentage / 100)
          .animate(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weaponSocketHashes = widget.weapon.sockets;
    final destinyPerkProvider = Provider.of<DestinyPerkProvider>(context);

    int itemCount =
        widget.godroll['masterworks'].length; // Total number of masterworks
    double itemHeight = 80; // Approximate height per item
    double listViewHeight =
        itemHeight * itemCount; // Total height of the ListView

    int modCount = widget.godroll['mods'].length;
    double modHeight = 80;
    double modviewheight = modHeight * modCount;

    int comboCount = widget.godroll['combos'].length;
    double comboHeight = 80;
    double comboviewheight = comboHeight * comboCount;

    final List<DestinyInventoryItemDefinition?> mainPerkDetails = [1, 2, 3, 4]
        .map((index) => destinyPerkProvider
            .getPerk(weaponSocketHashes![index].plugHash.toString()))
        .toList();

    List<int> mainPerkHashes = [];
    for (var perkDetail in mainPerkDetails) {
      if (perkDetail != null) {
        mainPerkHashes.add(perkDetail.hash!);
      }
    }

    if (widget.godroll['sockets_details'] != null &&
        widget.godroll['sockets_details'].length > 0) {
      return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFda3e52),
              secondary: Color(0xFFf0c330),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: 10,
                    bottom: 10),
                child: Text("Community Best Perks",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                    )),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1f2233),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) => Container(
                                  height: 15,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(
                                        color: Colors.white60, width: 2),
                                  ),
                                  child: LinearProgressIndicator(
                                    value: _animation.value,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "0%",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            widget.godroll['sockets_details'].length,
                            (i) {
                              var socketDetailsList = jsonDecode(
                                      widget.godroll['sockets_details'][i])
                                  as List<dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  socketDetailsList.length,
                                  (j) {
                                    final socketHash = socketDetailsList[j]
                                            ["socketHash"]
                                        .toString();
                                    final perkDetail =
                                        destinyPerkProvider.getPerk(socketHash);

                                    if (i == 3) {
                                      print("Socket Hash: $socketHash");
                                      print(
                                          "Main Perk Hash: ${mainPerkHashes[i]}");
                                    }
                                    var theoryCraft =
                                        widget.godroll['theory_craft'];
                                    var category;

                                    var perkTheory = theoryCraft.firstWhere(
                                      (theory) =>
                                          theory['data_id'] == socketHash,
                                      orElse: () => null,
                                    );

                                    if (perkTheory != null) {
                                      category = perkTheory['category'];
                                    }

                                    if (perkDetail == null) {
                                      return const SizedBox();
                                    }
                                    return Row(
                                      children: [
                                        if (perkDetail
                                            .displayProperties!.hasIcon!)
                                          Column(
                                            children: [
                                              Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                                103, 58, 183, 1)
                                                            .withOpacity(0.8),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Image.network(
                                                        "https://www.bungie.net${perkDetail.displayProperties?.icon ?? ''}",
                                                        width: 50,
                                                        height: 50,
                                                      ),
                                                    ),
                                                  ),
                                                  if (mainPerkHashes.contains(
                                                      socketDetailsList[j]
                                                          ['socketHash']))
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.yellow,
                                                            spreadRadius: 4,
                                                            blurRadius: 8,
                                                          ),
                                                        ],
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            const Color
                                                                .fromRGBO(103,
                                                                58, 183, 1),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Image.network(
                                                            "https://www.bungie.net${perkDetail.displayProperties?.icon ?? ''}",
                                                            width: 50,
                                                            height: 50,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (category != null)
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        height: 25,
                                                        width: 25,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: () {
                                                          switch (category) {
                                                            case 0:
                                                              return Container(); // Empty container for category 0
                                                            case 1:
                                                              return SvgPicture
                                                                  .asset(
                                                                      "assets/icons/pve-icon.svg");
                                                            case 2:
                                                              return SvgPicture
                                                                  .asset(
                                                                      "assets/icons/pvp-icon.svg");
                                                            case 3:
                                                              return SvgPicture
                                                                  .asset(
                                                                      "assets/icons/pve-pvp-icon.svg");
                                                            default:
                                                              return Container(); // Empty container for default case
                                                          }
                                                        }(),
                                                      ),
                                                    )
                                                ],
                                              ),
                                              Text(
                                                socketDetailsList[j]
                                                    ["percentage"],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: 30,
                    bottom: 10),
                child: Text("Community Best Masterworks",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                    )),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1f2233),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height:
                        listViewHeight, // Set dynamically calculated height here
                    child: ListView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(), // If you want to disable scrolling inside ListView
                      itemBuilder: (context, index) {
                        var masterworks = widget.godroll['masterworks'];
                        masterworks.sort((a, b) {
                          double percentageA =
                              double.parse(a['percentage'].split('%')[0]);
                          double percentageB =
                              double.parse(b['percentage'].split('%')[0]);
                          return percentageB
                              .compareTo(percentageA); // For descending order
                        });

                        var masterwork = masterworks[index];
                        var associatedMasterworkDetails =
                            destinyPerkProvider.getPerk(masterwork['id']);

                        if (associatedMasterworkDetails == null) {
                          return const SizedBox();
                        }

                        return Column(
                          children: [
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Image.network(
                                  "https://www.bungie.net${associatedMasterworkDetails.displayProperties?.icon ?? ''}",
                                ),
                              ),
                              title: Text(
                                associatedMasterworkDetails
                                        .displayProperties?.name!
                                        .replaceFirst('Tier 9: ', '') ??
                                    '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              subtitle: Text(
                                masterwork['percentage'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: itemCount,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: 30,
                    bottom: 10),
                child: Text("Community Best Mods",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                    )),
              ),
              Center(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2233),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: modviewheight,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var mods = widget.godroll['mods'];
                      mods.sort((a, b) {
                        double percentageA =
                            double.parse(a['percentage'].split('%')[0]);
                        double percentageB =
                            double.parse(b['percentage'].split('%')[0]);
                        return percentageB.compareTo(percentageA);
                      });

                      var mod = mods[index];
                      var associatedModDetails =
                          destinyPerkProvider.getPerk(mod['id']);

                      if (associatedModDetails == null) {
                        return const SizedBox();
                      }

                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.network(
                            "https://www.bungie.net${associatedModDetails.displayProperties?.icon ?? ''}",
                          ),
                        ),
                        title: Text(
                          associatedModDetails.displayProperties?.name ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          mod['percentage'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      );
                    },
                    itemCount: modCount,
                  ),
                ),
              )),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: 30,
                    bottom: 10),
                child: Text("Popular Perk Combos",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 20,
                    )),
              ),
              Center(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: const Color(0xFF1f2233),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: comboviewheight,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 1.8,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var combos = widget.godroll['combos'];
                      combos.sort((a, b) {
                        double percentageA =
                            double.parse(a['percentage'].split('%')[0]);
                        double percentageB =
                            double.parse(b['percentage'].split('%')[0]);
                        return percentageB.compareTo(percentageA);
                      });

                      var combo = combos[index];
                      var associatedCombo1Details =
                          destinyPerkProvider.getPerk(combo['perk1_hash']);

                      var associatedCombo2Details =
                          destinyPerkProvider.getPerk(combo['perk2_hash']);

                      if (associatedCombo1Details == null ||
                          associatedCombo2Details == null) {
                        return const SizedBox();
                      }

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    const Color.fromRGBO(103, 58, 183, 1)
                                        .withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Image.network(
                                    "https://www.bungie.net${associatedCombo1Details.displayProperties?.icon ?? ''}",
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              CircleAvatar(
                                radius: 25,
                                backgroundColor:
                                    const Color.fromRGBO(103, 58, 183, 1)
                                        .withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Image.network(
                                    "https://www.bungie.net${associatedCombo2Details.displayProperties?.icon ?? ''}",
                                  ),
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: AutoSizeText(
                              "${associatedCombo1Details.displayProperties?.name} +\n${associatedCombo2Details.displayProperties?.name}",
                              style: GoogleFonts.lato(
                                  color: Colors.white, fontSize: 16),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(
                            combo['percentage'],
                            style: GoogleFonts.lato(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      );
                    },
                    itemCount: comboCount,
                  ),
                ),
              )),
            ],
          ));
    } else {
      return const SizedBox();
    }
  }
}

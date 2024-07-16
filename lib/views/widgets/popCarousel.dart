import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/item_icon.dart';

class PopularWeaponsCarousel extends StatefulWidget {
  final List<dynamic> popularWeapons;
  final dynamic weaponDetailsBox;
  final List<dynamic> godRollList;
  final List<dynamic> perkDetailsList;

  PopularWeaponsCarousel(
      {required this.popularWeapons,
      required this.weaponDetailsBox,
      required this.godRollList,
      required this.perkDetailsList});

  @override
  _PopularWeaponsCarouselState createState() => _PopularWeaponsCarouselState();
}

class _PopularWeaponsCarouselState extends State<PopularWeaponsCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider.builder(
            itemCount: widget.popularWeapons.length,
            itemBuilder: (context, index, realIndex) {
              var popWeapon = widget.popularWeapons[index].toString();
              var popAssociatedWeaponDetails = widget.weaponDetailsBox?.values
                  .firstWhere(
                      (weaponDetails) =>
                          weaponDetails['id'].toString() == popWeapon,
                      orElse: () => null);

              var associatedGodRoll = widget.godRollList.firstWhere(
                  (godRoll) => godRoll['weaponHash'].toString() == popWeapon,
                  orElse: () => null);

              var bestMasterwork;
              var bestMod;
              var bestModDetails;
              var bestMasterworkDetails;

              if (associatedGodRoll != null) {
                // Sort the masterworks in descending order of their percentage
                if (associatedGodRoll['masterworks'] != null) {
                  if (associatedGodRoll['masterworks'].isNotEmpty) {
                    associatedGodRoll['masterworks'].sort((a, b) {
                      var percentageA = double.parse(
                          a['percentage'].split(' ')[0].replaceAll('%', ''));
                      var percentageB = double.parse(
                          b['percentage'].split(' ')[0].replaceAll('%', ''));
                      return percentageB.compareTo(percentageA);
                    });

                    bestMasterwork = associatedGodRoll['masterworks'][0];

                    print("bestMasterwork: $bestMasterwork");
                  }
                }

                if (bestMasterwork != null) {
                  bestMasterworkDetails = widget.perkDetailsList.firstWhere(
                      (perkDetails) =>
                          perkDetails != null &&
                          perkDetails.containsKey('hash') &&
                          perkDetails['hash'].toString() ==
                              bestMasterwork['id'].toString(),
                      orElse: () => null);
                }

                if (associatedGodRoll['mods'] != null) {
                  if (associatedGodRoll['mods'].isNotEmpty) {
                    associatedGodRoll['mods'].sort((a, b) {
                      var percentageA = double.parse(
                          a['percentage'].split(' ')[0].replaceAll('%', ''));
                      var percentageB = double.parse(
                          b['percentage'].split(' ')[0].replaceAll('%', ''));
                      return percentageB.compareTo(percentageA);
                    });

                    // Select the mod with the highest percentage
                    bestMod = associatedGodRoll['mods'][0];
                    print("bestMod: $bestMod");
                  }
                }

                if (bestMod != null) {
                  bestModDetails = widget.perkDetailsList.firstWhere(
                      (perkDetails) =>
                          perkDetails != null &&
                          perkDetails.containsKey('hash') &&
                          perkDetails['hash'].toString() ==
                              bestMod['id'].toString(),
                      orElse: () => null);
                }
              }

              var godRollPerks = [];

              if (associatedGodRoll != null) {
                for (var slot in associatedGodRoll['sockets_details']) {
                  if (slot.isNotEmpty) {
                    var bestPerk = slot[0];
                    godRollPerks.add(bestPerk);
                  }
                }
              }

              var godRollPerkDetails = [];

              for (var perk in godRollPerks) {
                var perkDetails = widget.perkDetailsList.firstWhere(
                    (perkDetails) =>
                        perkDetails != null &&
                        perkDetails.containsKey('hash') &&
                        perkDetails['hash'].toString() ==
                            perk['socketHash'].toString(),
                    orElse: () => null);
                if (perkDetails != null) {
                  godRollPerkDetails.add(perkDetails);
                }
              }

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1f2233),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (popAssociatedWeaponDetails != null)
                      Row(
                        children: [
                          Container(
                            height: 70,
                            child: WeaponIcon(
                              destinyWeapon: popAssociatedWeaponDetails,
                              showDetails: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              popAssociatedWeaponDetails['name'].toString(),
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (godRollPerkDetails.isNotEmpty &&
                        popAssociatedWeaponDetails != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            Text(
                              "God Roll Perks: ",
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            for (var perkDetail in godRollPerkDetails)
                              if (perkDetail != null)
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.lightBlue,
                                  backgroundImage: NetworkImage(
                                    "https://www.bungie.net${perkDetail['displayProperties']['icon']}",
                                  ),
                                ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          "Best Mods: ",
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        if (bestMasterworkDetails != null)
                          Image.network(
                            "https://www.bungie.net${bestMasterworkDetails['displayProperties']['icon']}",
                            height: 40,
                          ),
                        const SizedBox(width: 36),
                        if (bestModDetails != null)
                          Image.network(
                            "https://www.bungie.net${bestModDetails['displayProperties']['icon']}",
                            height: 40,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              aspectRatio: 2.0,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.popularWeapons.map((url) {
            int index = widget.popularWeapons.indexOf(url);
            return Container(
              width: 20.0, // Increase the width to make the shape a pill
              height: 4.0, // Decrease the height to make the shape a pill
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    2.0), // Add this line to make the corners rounded
                color: _current == index
                    ? Colors.white
                    : const Color.fromRGBO(
                        200, 200, 200, 0.4), // Inactive dot color
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

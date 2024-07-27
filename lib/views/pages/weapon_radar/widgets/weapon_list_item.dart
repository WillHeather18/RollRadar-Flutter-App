import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:god_roll_app/views/widgets/godRollPie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:god_roll_app/views/widgets/item_icon.dart';
import 'package:god_roll_app/views/pages/detail_page/detail_page.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/custombottomsheet.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/services/god-roll-service.dart';
import 'package:provider/provider.dart';

class WeaponListItem extends StatefulWidget {
  final FullItem weapon;
  final List<DestinyInventoryItemDefinition?> mainPerkDetails;

  const WeaponListItem({
    Key? key,
    required this.weapon,
    required this.mainPerkDetails,
  }) : super(key: key);

  @override
  State<WeaponListItem> createState() => _WeaponListItemState();
}

class _WeaponListItemState extends State<WeaponListItem> {
  Map<String, dynamic>? _godRoll;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchGodRoll();
  }

  Future<void> _fetchGodRoll() async {
    GodRollService godRollService = GodRollService();
    final godRoll =
        await godRollService.getGodRoll(widget.weapon.item.itemHash.toString());
    if (mounted) {
      setState(() {
        _godRoll = godRoll;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weaponName =
        widget.weapon.manifestData!.displayProperties!.name ?? "Unknown";
    GodRollService godRollService = GodRollService();
    final destinyPerkProvider = Provider.of<DestinyPerkProvider>(context);
    final allPerkOptions = destinyPerkProvider.getAllWeaponPerks(widget.weapon);
    double weaponPercentage = 0;
    if (_godRoll != null && weaponName != "Ergo Sum") {
      weaponPercentage =
          godRollService.calculateWeaponPercentage(_godRoll!, allPerkOptions);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0x800f0f23), // Adjusted alpha value for less opacity
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              CustomBottomSheetRoute(
                child: DetailPage(
                  weapon: widget.weapon,
                ),
              ),
            );
          },
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 75,
                        width: 75,
                        child: Hero(
                          tag: widget.weapon.item.itemInstanceId!,
                          child: WeaponIcon(
                            weaponInstance: widget.weapon,
                            showDetails: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 75,
                        child: GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  weaponName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                ),
                                SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: Icon(
                                    _isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  if (_godRoll != null &&
                      weaponPercentage != 0 &&
                      weaponName != "Ergo Sum")
                    SizedBox(
                        height: 35,
                        child: GodRollPie(percentage: weaponPercentage)),
                ],
              ),
              Row(
                children: [
                  if (_isExpanded) ...[
                    const SizedBox(
                        height:
                            10), // Add some space between weapon name and perks
                    Wrap(
                      spacing: 4.0,
                      children: List<Widget>.generate(allPerkOptions.length,
                          (slotIndex) {
                        var slotPerks = allPerkOptions[slotIndex];
                        return Column(
                          children: List<Widget>.generate(slotPerks.length,
                              (perkIndex) {
                            var perk = allPerkOptions[slotIndex][perkIndex];
                            if (perk.displayProperties != null) {
                              bool isPerkGodRoll = false;
                              String slotPosition = '';
                              if (_godRoll != null) {
                                isPerkGodRoll = godRollService.isPerkGodRoll(
                                    _godRoll!,
                                    perk.hash!,
                                    perk.displayProperties!.name!,
                                    slotIndex);
                                slotPosition =
                                    godRollService.calculateSlotPosition(
                                        _godRoll!,
                                        perk.hash!,
                                        perk.displayProperties!.name!,
                                        slotIndex);
                              }
                              print(slotPosition);
                              return Column(children: [
                                if (isPerkGodRoll)
                                  ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.yellow,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.network(
                                      "https://www.bungie.net${perk.displayProperties?.icon ?? ''}",
                                      width: 40, // Adjust size as needed
                                      height: 40, // Adjust size as needed
                                    ),
                                  )
                                else
                                  Image.network(
                                    "https://www.bungie.net${perk.displayProperties?.icon ?? ''}",
                                    width: 40, // Adjust size as needed
                                    height: 40, // Adjust size as needed
                                  ),
                                if (_godRoll != null)
                                  Text(slotPosition,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white)),
                              ]);
                            } else {
                              return Container(); // Or some placeholder widget
                            }
                          }),
                        );
                      }),
                    ),
                  ],
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

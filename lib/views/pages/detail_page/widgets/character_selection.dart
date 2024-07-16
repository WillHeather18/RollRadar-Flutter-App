import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:god_roll_app/providers/destinycharacterprovider.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:google_fonts/google_fonts.dart';

class CharacterSelectionPanel extends StatelessWidget {
  final FullItem weapon;
  final bool isMovingWeapon;
  final bool isEquippingWeapon;

  const CharacterSelectionPanel({
    Key? key,
    required this.weapon,
    required this.isMovingWeapon,
    required this.isEquippingWeapon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var destinyCharacterProvider =
        Provider.of<DestinyCharacterProvider>(context);
    var destinyCharacters = destinyCharacterProvider.characters;
    var destinyCharactersList = destinyCharacters.values.toList();
    var transferableCharacters = destinyCharacters.keys.toList();

    const characterImageHeight = 40.0;
    const characterImageBorderRadius = 2.0;

    return Container(
      color: const Color(0xFF0f0f23),
      height: 75,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        if (isMovingWeapon || isEquippingWeapon)
          const LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Color(0xFF0f0f23),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equip on:',
                    style: GoogleFonts.orbitron(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...List.generate(
                        destinyCharactersList.length,
                        (index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: characterImageHeight,
                              height: characterImageHeight,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    characterImageBorderRadius),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://www.bungie.net${destinyCharactersList[index].emblemPath}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer to:',
                    style: GoogleFonts.orbitron(
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      ...transferableCharacters.map(
                        (character) {
                          int characterId = int.parse(character);
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: characterImageHeight,
                              height: characterImageHeight,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    characterImageBorderRadius),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://www.bungie.net${destinyCharactersList.firstWhere((element) => element.characterId == characterId.toString()).emblemPath}',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                      if (weapon.item.location != 0)
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: characterImageHeight,
                            width: characterImageHeight,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  characterImageBorderRadius),
                              color: const Color(0xFF0f0f23),
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
                              padding: const EdgeInsets.all(2.0),
                              child: SvgPicture.asset(
                                'assets/icons/vault.svg',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

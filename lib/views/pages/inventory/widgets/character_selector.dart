import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:god_roll_app/tools/lookup.dart';

class CharacterSelection extends StatelessWidget {
  final Map<String, DestinyCharacterComponent> destinyCharacters;
  final ValueNotifier<int> selectedCharacterId;
  final Function(int, String, int) onCharacterSelected;

  const CharacterSelection({
    Key? key,
    required this.destinyCharacters,
    required this.selectedCharacterId,
    required this.onCharacterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: const Color(0xFF282c34),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...List.generate(
              destinyCharacters.length,
              (index) {
                var key = destinyCharacters.keys.elementAt(index);
                var destinyCharacter = destinyCharacters[key];
                int characterId = int.parse(destinyCharacter!.characterId!);
                bool isSelected = selectedCharacterId.value == characterId;
                return GestureDetector(
                  onTap: () {
                    onCharacterSelected(
                      characterId,
                      '${raceTypeLookup(destinyCharacter.raceType!.index)} ${classTypeLookup(destinyCharacter.classType!.index)}',
                      destinyCharacter.light!,
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://www.bungie.net${destinyCharacter.emblemPath!}',
                        ),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.yellow, width: 2)
                          : null,
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
            GestureDetector(
              onTap: () {
                onCharacterSelected(0, 'Inventory', 0);
              },
              child: Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0f0f23),
                  borderRadius: BorderRadius.circular(8),
                  border: selectedCharacterId.value == 0
                      ? Border.all(color: Colors.yellow, width: 2)
                      : null,
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InventorySearchBar extends StatelessWidget {
  final bool isSearchActive;
  final TextEditingController searchController;
  final String currentCharacterName;
  final bool showPower;
  final int currentPower;

  const InventorySearchBar({
    super.key,
    required this.isSearchActive,
    required this.searchController,
    required this.currentCharacterName,
    required this.showPower,
    required this.currentPower,
  });

  @override
  Widget build(BuildContext context) {
    return isSearchActive
        ? TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search weapons...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                currentCharacterName,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 18),
              ),
              if (showPower)
                Row(
                  children: [
                    Container(
                      height: 15,
                      width: 15,
                      child: SvgPicture.asset(
                        'assets/icons/light.svg',
                        color: Colors.yellow,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      currentPower.toString(),
                      style:
                          GoogleFonts.lato(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
            ],
          );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilter extends StatefulWidget {
  final bool userWeapon;
  final ValueChanged<List<dynamic>> onWeaponsFiltered;

  final bool showFilters;
  final ValueChanged<bool> onShowFilters;

  final TextEditingController searchController;

  final List<dynamic> weaponDetailsList;
  final List<dynamic> weapons;

  final int characterId;

  const SearchFilter(
      {super.key,
      required this.onWeaponsFiltered,
      required this.weaponDetailsList,
      required this.weapons,
      required this.searchController,
      required this.showFilters,
      required this.onShowFilters,
      required this.characterId,
      required this.userWeapon});

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  double _minScoreFilter = 0; // Minimum score filter, scores range from 0 to 4
  double _maxScoreFilter = 4; // Maximum score filter, max score is
  late List<dynamic> filteredWeapons;

  @override
  void initState() {
    super.initState();
  }

  final List<String> _weaponTypes = [
    'All',
    'Auto Rifle',
    'Scout Rifle',
    'Pulse Rifle',
    'Hand Cannon',
    'Sidearm',
    'Submachine Gun',
    'Shotgun',
    'Sniper Rifle',
    'Fusion Rifle',
    'Linear Fusion Rifle',
    'Rocket Launcher',
    'Grenade Launcher',
    'Sword',
    'Machine Gun',
    'Trace Rifle',
    'Bow',
    'Glaive'
  ];

  String _selectedWeaponType = 'All'; // Default to 'All' weapon type

  String _selectedAmmoType = 'All'; // Default to 'All' weapon type

  final List<String> _damageTypes = [
    'Kinetic',
    'Solar',
    'Arc',
    'Void',
    'Stasis',
    'Strand'
  ];

  final List<String> _damageTypesUrls = [
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_3385a924fd3ccb92c343ade19f19a370.png',
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_2a1773e10968f2d088b97c22b22bba9e.png',
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_092d066688b879c807c3b460afdd61e6.png',
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_ceb2f6197dccf3958bb31cc783eb97a0.png',
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_530c4c3e7981dc2aefd24fd3293482bf.png',
    '/common/destiny2_content/icons/DestinyDamageTypeDefinition_b2fe51a94f3533f97079dfa0d27a4096.png'
  ];

  String _selectedDamageType = 'All';

  final List<String> _weaponRarities = [
    'All',
    'Common',
    'Rare',
    'Legendary',
    'Exotic'
  ];

  String _selectedWeaponRarity = 'All';

  List<dynamic> _filterWeapons() {
    String searchTerm = widget.searchController.text.toLowerCase();

    // Filter by characterId if not showing the Vault (Vault ID = 0)
    filteredWeapons = widget.weapons.where((weapon) {
      int weaponCharacterId = 0;

      var weaponDetail = widget.weaponDetailsList.firstWhere(
          (detail) =>
              detail['id'] ==
              weapon[
                  'weaponHash'], // Make sure to match the correct detail identifier
          orElse: () => null);

      try {
        weaponCharacterId = int.parse(weapon['characterId']);
      } catch (e) {}

      bool matchesCharacterId = widget.characterId == weaponCharacterId;
      bool matchesDamageType = _selectedDamageType == 'All' ||
          (weaponDetail != null &&
              weaponDetail['damageTypes'].contains(_selectedDamageType));
      bool matchesAmmoType = _selectedAmmoType == 'All' ||
          (weaponDetail != null &&
              weaponDetail['ammoType'] == _selectedAmmoType);
      bool matchesWeaponType = _selectedWeaponType == 'All' ||
          (weaponDetail != null && weaponDetail['type'] == _selectedWeaponType);
      bool matchesWeaponRarity = _selectedWeaponRarity == 'All' ||
          (weaponDetail != null &&
              weaponDetail['rarity'] == _selectedWeaponRarity);
      bool matchesSearchTerm = searchTerm.isEmpty ||
          (weaponDetail != null &&
              weaponDetail['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchTerm));

      return matchesCharacterId &&
          matchesDamageType &&
          matchesAmmoType &&
          matchesWeaponType &&
          matchesWeaponRarity &&
          matchesSearchTerm;
    }).where((weapon) {
      // Apply score filter only if userWeapon is true
      if (widget.userWeapon) {
        double score = 0.0;
        if (weapon['score'] != null) {
          List<String> scoreParts = weapon['score'].split('/');
          if (scoreParts.length == 2) {
            int numerator = int.tryParse(scoreParts[0]) ?? 0;
            int denominator = int.tryParse(scoreParts[1]) ??
                1; // Default to 1 to avoid division by zero
            score = numerator /
                (denominator.isFinite && denominator != 0 ? denominator : 1);
          }
        }
        return score >= (_minScoreFilter / 4) && score <= (_maxScoreFilter / 4);
      }
      return true; // If userWeapon is false, don't apply the score filter
    }).toList();

    print("sending back filtered weapons ${filteredWeapons.length}");

    widget.onWeaponsFiltered(filteredWeapons);
    return filteredWeapons;
  }

  void _resetFilters() {
    if (mounted) {
      setState(() {
        // Clear the search text
        // Reset score filters to default values
        _minScoreFilter = 0.0;
        _maxScoreFilter = 4.0;

        _selectedDamageType = 'All';
        _selectedAmmoType = 'All';
        _selectedWeaponType = 'All';
        _selectedWeaponRarity = 'All';
        // Reset any other filters you have to their default values
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showFilters) {
      return Container(
        color: const Color(0xFF1f2233),
        child: Column(
          children: [
            const SizedBox(height: 2.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  onPressed: () {
                    _resetFilters();
                  },
                  tooltip: 'Reset Filters',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    widget.onShowFilters(false);
                  },
                  tooltip: 'Close Filters',
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Weapon Type: ',
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 18)), // Styling text

                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 120,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(
                            0xFF1f2233), // Darker color for the background
                        border: Border.all(
                            color: Colors.grey.shade700), // Add a subtle border
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedWeaponType,
                          dropdownColor: const Color(
                              0xFF2a2d3d), // Dark theme dropdown color
                          style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 14), // Styling text
                          items: _weaponTypes
                              .map((weaponType) => DropdownMenuItem(
                                    value: weaponType,
                                    child: Text(weaponType,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              if (mounted) {
                                setState(() {
                                  _selectedWeaponType = value;
                                });
                              }
                              _filterWeapons();
                            }
                          },
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white70), // Dropdown icon color
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Weapon Rarity: ',
                        style: GoogleFonts.roboto(
                            color: Colors.white, fontSize: 18)),
                    const SizedBox(width: 10),
                    Container(
                      height: 40,
                      width: 120,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(
                            0xFF1f2233), // Darker color for the background
                        border: Border.all(
                            color: Colors.grey.shade700), // Add a subtle border
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedWeaponRarity,
                          dropdownColor: const Color(
                              0xFF2a2d3d), // Dark theme dropdown color
                          style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 14), // Styling text
                          items: _weaponRarities
                              .map((weaponRarity) => DropdownMenuItem(
                                    value: weaponRarity,
                                    child: Text(weaponRarity,
                                        style: GoogleFonts.roboto(
                                            color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              if (mounted) {
                                setState(() {
                                  _selectedWeaponRarity = value;
                                });
                              }
                              _filterWeapons();
                            }
                          },
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.white70), // Dropdown icon color
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.5,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _selectedAmmoType = 'All';
                                  _filterWeapons();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedAmmoType = 'Primary';
                          });
                        }
                        _filterWeapons();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 40,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Transform.scale(
                          scale: _selectedAmmoType == 'Primary' ? 1.1 : 1.0,
                          child: SvgPicture.asset(
                            'assets/icons/ammo-primary.svg',
                            color: _selectedAmmoType == 'Primary' ||
                                    _selectedAmmoType == 'All'
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedAmmoType = 'Special';
                          });
                        }
                        _filterWeapons();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 40,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Transform.scale(
                          scale: _selectedAmmoType == 'Special' ? 1.1 : 1.0,
                          child: SvgPicture.asset(
                            'assets/icons/ammo-special.svg',
                            color: _selectedAmmoType == 'Special' ||
                                    _selectedAmmoType == 'All'
                                ? null
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (mounted) {
                          setState(() {
                            _selectedAmmoType = 'Heavy';
                          });
                        }
                        _filterWeapons();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 40,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Transform.scale(
                          scale: _selectedAmmoType == 'Heavy' ? 1.1 : 1.0,
                          child: SvgPicture.asset(
                            'assets/icons/ammo-heavy.svg',
                            color: _selectedAmmoType == 'Heavy' ||
                                    _selectedAmmoType == 'All'
                                ? null
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Transform.scale(
                          scale: 1.5,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _selectedDamageType = 'All';
                                });
                              }
                              _filterWeapons();
                            },
                          ),
                        ),
                      ),
                    ),
                    ..._damageTypes.take(3).map((damageType) {
                      bool isSelected = _selectedDamageType == damageType;
                      return GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _selectedDamageType = damageType;
                            });
                          }
                          _filterWeapons();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 40,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Transform.scale(
                            scale: isSelected ? 1.1 : 1.0,
                            child: Center(
                              child: Image.network(
                                  "https://bungie.net" +
                                      _damageTypesUrls[
                                          _damageTypes.indexOf(damageType)],
                                  color:
                                      isSelected || _selectedDamageType == 'All'
                                          ? null
                                          : Colors.grey),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 40,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    ..._damageTypes
                        .skip(_damageTypes.length - 3)
                        .map((damageType) {
                      bool isSelected = _selectedDamageType == damageType;
                      return GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              _selectedDamageType = damageType;
                            });
                          }
                          _filterWeapons();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 40,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Transform.scale(
                            scale: isSelected ? 1.1 : 1.0,
                            child: Center(
                              child: Image.network(
                                "https://bungie.net" +
                                    _damageTypesUrls[
                                        _damageTypes.indexOf(damageType)],
                                color: isSelected ||
                                        _selectedDamageType == 'All'
                                    ? null
                                    : Colors
                                        .grey, // Retain the original color if selected
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                if (widget.userWeapon)
                  Column(
                    children: [
                      Text(
                        'Min score: ${_minScoreFilter.toInt()}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      // Minimum score slider
                      Slider(
                        value: _minScoreFilter,
                        min: 0,
                        max: 4,
                        divisions: 4, // Allows for quarter scores
                        label: 'Min score: ${_minScoreFilter.toInt()}',
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _minScoreFilter = value; // Re-filter the list
                            });
                          }
                          _filterWeapons();
                        },
                      ),
                      Text(
                        'Max score: ${_maxScoreFilter.toInt()}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      // Maximum score slider
                      Slider(
                        value: _maxScoreFilter,
                        min: 0,
                        max: 4,
                        divisions: 4, // Allows for quarter scores
                        label: 'Max score: ${_maxScoreFilter.toInt()}',
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _maxScoreFilter = value; // Re-filter the list
                            });
                          }
                          _filterWeapons();
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

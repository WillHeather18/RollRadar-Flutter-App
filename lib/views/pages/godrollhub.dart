import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart'; // Ensure this is the correct path
import '../widgets/item_icon.dart'; // Ensure this is the correct path
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/popCarousel.dart'; // Import the PopularWeaponsCarousel widget
import '../providers/godrollsprovider.dart';
import 'package:provider/provider.dart';
import '../widgets/inventoryStats.dart'; // Import the InventoryStats widget

class GodrollHub extends StatefulWidget {
  @override
  _GodrollHubState createState() => _GodrollHubState();
}

class _GodrollHubState extends State<GodrollHub> {
  Box<dynamic>? perkDetailsBox;
  Box<dynamic>? weaponDetailsBox;
  bool _isSearching = false; // State to toggle search mode
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredWeapons = [];

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

  final List<String> _ammoTypes = [
    'Primary',
    'Special',
    'Heavy',
  ];

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

  final List<String> _weaponSlots = ['Primary', 'Energy', 'Power'];

  String _selectedWeaponSlot = 'All';

  final List<String> _weaponRarities = [
    'All',
    'Common',
    'Rare',
    'Legendary',
    'Exotic'
  ];

  String _selectedWeaponRarity = 'All';

  List<dynamic> popularWeapons = [];

  bool isLoading = true;
  int _current = 0;

  @override
  void initState() {
    super.initState();

    Future.wait([
      Hive.openBox('PerkDetails').then((box) {
        setState(() => perkDetailsBox = box);
      }),
      Hive.openBox('WeaponsDetails').then((box) {
        setState(() {
          weaponDetailsBox = box;
          _updateFilteredWeapons(
              initial:
                  true); // This ensures _filteredWeapons is initialized with the correct list.
          _filteredWeapons = weaponDetailsBox?.values.toList() ??
              [].where((weapon) => weapon["randomRoll"] == true).toList();
        });
      }),
      fetchPopularWeapons().then((value) {
        setState(() {
          popularWeapons = value[0]['popular_ids'];
        });
      }),
    ]).then((_) {
      setState(() {
        isLoading = false;
      });
    });

    _searchController.addListener(() {
      // Add a listener to the search controller
      _updateFilteredWeapons(); // Call the update method when the search query changes
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateFilteredWeapons);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchPopularWeapons() async {
    final response = await http.get(Uri.parse(
        'https://rollradaroauth.azurewebsites.net/getPopularWeapons'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load popular weapons');
    }
  }

  void _updateFilteredWeapons({bool initial = false}) {
    print("Current filters:");
    print("Selected ammo type: $_selectedAmmoType");
    print("Selected damage type: $_selectedDamageType");

    setState(() {
      _filteredWeapons = weaponDetailsBox?.values.toList() ??
          [].where((weapon) => weapon["randomRoll"] == true).toList();
    });

    // Start with all weapons from the provider
    List<dynamic> weapons = List.from(_filteredWeapons);

    // Filter by characterId if not showing the Vault (Vault ID = 0)
    weapons = weapons.where((weapon) {
      bool matchesDamageType = _selectedDamageType == 'All' ||
          (weapon != null && weapon['damageTypes'][0] == _selectedDamageType);
      bool matchesAmmoType = _selectedAmmoType == 'All' ||
          (weapon != null && weapon['ammoType'] == _selectedAmmoType);
      bool matchesWeaponType = _selectedWeaponType == 'All' ||
          (weapon != null && weapon['type'] == _selectedWeaponType);
      bool matchesWeaponRarity = _selectedWeaponRarity == 'All' ||
          (weapon != null && weapon['rarity'] == _selectedWeaponRarity);

      return matchesDamageType &&
          matchesAmmoType &&
          matchesWeaponType &&
          matchesWeaponRarity;
    }).toList();

    // Apply name and score filters
    setState(() {
      _filteredWeapons = weapons.where((weapon) {
        bool matchesName = weapon['name']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        return matchesName;
      }).toList();
    });

    // Print the filtered weapons count after updating the state
    print("Filtered weapons count: ${_filteredWeapons.length}");
  }

  void _resetFilters() {
    setState(() {
      // Clear the search text
      _searchController.clear();
      // Reset score filters to default values

      _selectedDamageType = 'All';
      _selectedAmmoType = 'All';
      _selectedWeaponType = 'All';
      _selectedWeaponRarity = 'All';
      _selectedWeaponSlot = 'All';
      // Reset any other filters you have to their default values

      // After resetting filters, update the filtered weapons list
      _updateFilteredWeapons(initial: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var godrollsProvider = Provider.of<GodRollsProvider>(context);
    var godRollsList = godrollsProvider.godRolls;

    return Scaffold(
      backgroundColor: Colors.grey, // Background color like in WeaponRadar
      appBar: _isSearching ? _buildSearchAppBar() : _buildAppBar(),
      body: Column(
        children: [
          if (_showFilters)
            Container(
              color: const Color(0xFF1f2233),
              child: Column(
                children: [
                  const SizedBox(height: 2.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.delete_sweep, color: Colors.white),
                        onPressed: () {
                          _resetFilters();
                        },
                        tooltip: 'Reset Filters',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _showFilters = false;
                          });
                        },
                        tooltip: 'Close Filters',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Weapon Type: ',
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 18)), // Styling text

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
                              color:
                                  Colors.grey.shade700), // Add a subtle border
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
                                      child: Text(weaponType,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white)),
                                      value: weaponType,
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWeaponType = value;
                                  _updateFilteredWeapons();
                                });
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
                              color:
                                  Colors.grey.shade700), // Add a subtle border
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
                                      child: Text(weaponRarity,
                                          style: GoogleFonts.roboto(
                                              color: Colors.white)),
                                      value: weaponRarity,
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _selectedWeaponRarity = value;
                                  _updateFilteredWeapons();
                                });
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
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedAmmoType = 'All';
                                  _updateFilteredWeapons();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAmmoType = 'Primary';
                            _updateFilteredWeapons();
                          });
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
                          setState(() {
                            _selectedAmmoType = 'Special';
                            _updateFilteredWeapons();
                          });
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
                          setState(() {
                            _selectedAmmoType = 'Heavy';
                            _updateFilteredWeapons();
                          });
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
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  _selectedDamageType = 'All';
                                  _updateFilteredWeapons();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      ..._damageTypes.take(3).map((damageType) {
                        bool isSelected = _selectedDamageType == damageType;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDamageType = damageType;
                              _updateFilteredWeapons();
                            });
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
                            setState(() {
                              _selectedDamageType = damageType;
                              _updateFilteredWeapons();
                            });
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
                  )
                ],
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          Text("Today's Popular Weapons",
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 20)),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: PopularWeaponsCarousel(
              popularWeapons: popularWeapons,
              weaponDetailsBox: weaponDetailsBox,
              godRollList: godRollsList,
              perkDetailsList: perkDetailsBox?.values.toList() ?? [],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            child: InventoryStats(
              weaponDetailsList: weaponDetailsBox?.values.toList() ?? [],
              perkDetailsList: perkDetailsBox?.values.toList() ?? [],
            ),
          )
        ],
      ),
      drawer:
          AppDrawer(), // Assuming you want the navigation drawer here as well
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF0f0f23),
      title: Text(
        'Godroll Hub',
        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF0f0f23),
      title: TextField(
        style: GoogleFonts.lato(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: GoogleFonts.orbitron(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
        ),
        autofocus: true,
        onChanged: (query) {
          setState(() {
            _searchController.text = query; // Update the search query
          });
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            setState(() => _showFilters = !_showFilters);
          },
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.text = ''; // Clear the search query
            });
          },
        ),
      ],
    );
  }
}

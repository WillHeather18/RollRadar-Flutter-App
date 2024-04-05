import 'package:flutter/material.dart';
import 'package:god_roll_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/weaponsprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weapondetailsprovider.dart';
import '../providers/characterdetailsprovider.dart';
import '../widgets/weaponsgrid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false; // Tracks if the search UI should be shown
  BannerAd? _bannerAd;

  double _minScoreFilter = 0; // Minimum score filter, scores range from 0 to 4
  double _maxScoreFilter = 4; // Maximum score filter, max score is

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

  bool _showFilters = false; // Tracks if the filters UI should be shown
  List<dynamic> _filteredWeapons = [];
  String currentCharacterName = 'Inventory';
  int currentPower = 0;
  bool showPower = false;
  int _selectedCharacterId = 0;

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateFilteredWeapons(initial: true));
    _searchController.addListener(_updateFilteredWeapons);
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateFilteredWeapons);
    _searchController.dispose();
    super.dispose();
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3312492533170432/1565277159', // Test ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _updateFilteredWeapons({bool initial = false}) {
    print("Current filters:");
    print("Min score: $_minScoreFilter");
    print("Max score: $_maxScoreFilter");
    print("Selected ammo type: $_selectedAmmoType");
    print("Selected damage type: $_selectedDamageType");
    print("Selected character ID: $_selectedCharacterId");

    var weaponDetailsList =
        Provider.of<WeaponDetailsProvider>(context, listen: false)
            .weaponDetails;
    var weaponsProvider = Provider.of<WeaponsProvider>(context, listen: false);

    // Start with all weapons from the provider
    List<dynamic> weapons = List.from(weaponsProvider.weapons);

    // Filter by characterId if not showing the Vault (Vault ID = 0)
    weapons = weapons.where((weapon) {
      int weaponCharacterId = 0;

      var weaponDetail = weaponDetailsList.firstWhere(
          (detail) =>
              detail['id'] ==
              weapon[
                  'weaponHash'], // Make sure to match the correct detail identifier
          orElse: () => null);

      try {
        weaponCharacterId = int.parse(weapon['characterId']);
      } catch (e) {
        print(
            'Error parsing characterId from weapon: ${weapon['characterId']}, error: $e');
      }

      bool matchesCharacterId = weaponCharacterId == _selectedCharacterId;
      bool matchesDamageType = _selectedDamageType == 'All' ||
          (weaponDetail != null &&
              weaponDetail['damageTypes'][0] == _selectedDamageType);
      bool matchesAmmoType = _selectedAmmoType == 'All' ||
          (weaponDetail != null &&
              weaponDetail['ammoType'] == _selectedAmmoType);
      bool matchesWeaponType = _selectedWeaponType == 'All' ||
          (weaponDetail != null && weaponDetail['type'] == _selectedWeaponType);
      bool matchesWeaponRarity = _selectedWeaponRarity == 'All' ||
          (weaponDetail != null &&
              weaponDetail['rarity'] == _selectedWeaponRarity);

      return matchesCharacterId &&
          matchesDamageType &&
          matchesAmmoType &&
          matchesWeaponType &&
          matchesWeaponRarity;
    }).toList();

    print(weapons.length);

    // Function to parse score and check if it matches filter criteria
    bool _matchesScoreFilter(Map weapon) {
      double score = 0.0;
      List<String> scoreParts = weapon['score'].split('/');
      if (scoreParts.length == 2) {
        int numerator = int.tryParse(scoreParts[0]) ?? 0;
        int denominator = int.tryParse(scoreParts[1]) ??
            1; // Default to 1 to avoid division by zero
        score = numerator / denominator;
      }
      return score >= (_minScoreFilter / 4) && score <= (_maxScoreFilter / 4);
    }

    print(weapons.length);

    // Apply name and score filters
    setState(() {
      _filteredWeapons = weapons.where((weapon) {
        bool matchesName = weapon['weaponName']
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
        return matchesName && _matchesScoreFilter(weapon);
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
      _minScoreFilter = 0.0;
      _maxScoreFilter = 4.0;

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
    double bannerAdHeight = _bannerAd?.size.height.toDouble() ?? 50.0;
    var characterDetailsProvider =
        Provider.of<CharacterDetailsProvider>(context);
    var characterDetails = characterDetailsProvider.characterDetails;
    print("inventory built, filtered weapon count${_filteredWeapons.length}");
    return Scaffold(
      backgroundColor: const Color(0xFF282c34),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearchActive
            ? TextField(
                controller: _searchController,
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
                    style:
                        GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
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
                          style: GoogleFonts.orbitron(
                              color: Colors.white, fontSize: 18),
                        )
                      ],
                    ),
                ],
              ),
        backgroundColor: const Color(0xFF0f0f23),
        elevation: 0,
        actions: <Widget>[
          if (_isSearchActive | _showFilters)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          IconButton(
            icon: Icon(_isSearchActive ? Icons.search_off : Icons.search,
                color: Colors.white),
            onPressed: () => setState(() => _isSearchActive = !_isSearchActive),
          ),
        ],
      ),
      body: Stack(children: [
        Column(
          children: <Widget>[
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
                          icon: const Icon(Icons.delete_sweep,
                              color: Colors.white),
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
                                color: Colors
                                    .grey.shade700), // Add a subtle border
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
                                color: Colors
                                    .grey.shade700), // Add a subtle border
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
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
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
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
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
                    ),
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
                        setState(() {
                          _minScoreFilter = value;
                          _updateFilteredWeapons(); // Re-filter the list
                        });
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
                        setState(() {
                          _maxScoreFilter = value;
                          _updateFilteredWeapons(); // Re-filter the list
                        });
                      },
                    ),
                  ],
                ),
              ),
            _showFilters
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: const Color(0xFF282c34),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...List.generate(
                            characterDetails['character_details'].length,
                            (index) {
                              int characterId = int.parse(
                                  characterDetails['character_details']
                                      .keys
                                      .toList()[index]);
                              bool isSelected =
                                  _selectedCharacterId == characterId;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCharacterId = characterId;
                                    currentPower =
                                        characterDetails['character_details']
                                            .values
                                            .toList()[index]['light'];
                                    showPower = true;
                                    currentCharacterName = characterDetails[
                                                'character_details']
                                            .values
                                            .toList()[index]['raceType'] +
                                        ' ' +
                                        characterDetails['character_details']
                                            .values
                                            .toList()[index]['classType'];
                                    _updateFilteredWeapons();
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://www.bungie.net${characterDetails['character_details'].values.toList()[index]['emblemPath']}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.yellow, width: 2)
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ], // No boxShadow for unselected characters
                                  ),
                                ),
                              );
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCharacterId = 0; // Vault selected
                                currentCharacterName = 'Inventory';
                                showPower = false;
                                _updateFilteredWeapons();
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0f0f23),
                                borderRadius: BorderRadius.circular(8),
                                border: _selectedCharacterId == 0
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
                  ),
            Expanded(
              child: WeaponWidget(
                filteredWeapons: _filteredWeapons,
                adHeight: bannerAdHeight,
              ),
            ),
          ],
        ),
        if (_bannerAd != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
      ]),
      drawer: AppDrawer(),
    );
  }
}

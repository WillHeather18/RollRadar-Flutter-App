import 'package:flutter/material.dart';
import 'package:god_roll_app/providers/destinycharacterprovider.dart';
import 'package:god_roll_app/views/widgets/banner_ad.dart';
import 'package:god_roll_app/views/pages/inventory/widgets/character_selector.dart';
import 'package:god_roll_app/views/pages/inventory/widgets/inventory_search_bar.dart';
import 'package:god_roll_app/views/widgets/app_drawer.dart';
import 'package:god_roll_app/views/pages/inventory/widgets/weaponsgrid.dart';
import 'package:provider/provider.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  bool _showFilters = false;
  String currentCharacterName = 'Inventory';
  int currentPower = 0;
  bool showPower = false;
  ValueNotifier<int> _selectedCharacterId = ValueNotifier<int>(0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    BannerAdWidget.initBannerAd();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void rebuildWidget() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double bannerAdHeight = BannerAdWidget.bannerAdHeight;
    var destinyCharacterProvider =
        Provider.of<DestinyCharacterProvider>(context);
    var destinyCharacters = destinyCharacterProvider.characters;

    return Scaffold(
      backgroundColor: const Color(0xFF282c34),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: InventorySearchBar(
          isSearchActive: _isSearchActive,
          searchController: _searchController,
          currentCharacterName: currentCharacterName,
          showPower: showPower,
          currentPower: currentPower,
        ),
        backgroundColor: const Color(0xFF0f0f23),
        elevation: 0,
        actions: <Widget>[
          if (_isSearchActive | _showFilters)
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                if (mounted) {
                  setState(() => _showFilters = !_showFilters);
                }
              },
            ),
          IconButton(
            icon: Icon(_isSearchActive ? Icons.search_off : Icons.search,
                color: Colors.white),
            onPressed: () {
              if (mounted) {
                setState(() => _isSearchActive = !_isSearchActive);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              if (_showFilters) Container(),
              CharacterSelection(
                destinyCharacters: destinyCharacters,
                selectedCharacterId: _selectedCharacterId,
                onCharacterSelected: (characterId, characterName, power) {
                  if (mounted) {
                    setState(() {
                      _selectedCharacterId.value = characterId;
                      currentCharacterName = characterName;
                      currentPower = power;
                      showPower = power != 0;
                    });
                  }
                },
              ),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _selectedCharacterId,
                  builder: (context, value, child) {
                    return WeaponWidget(
                      characterIdNotifier: _selectedCharacterId,
                      adHeight: bannerAdHeight,
                      onRefresh: rebuildWidget,
                    );
                  },
                ),
              ),
            ],
          ),
          if (BannerAdWidget.bannerAd != null)
            const Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdWidget(),
            ),
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}

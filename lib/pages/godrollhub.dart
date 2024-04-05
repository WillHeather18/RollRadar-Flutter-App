import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/weapondetailsprovider.dart'; // Ensure this is the correct path
import '../widgets/app_drawer.dart'; // Ensure this is the correct path
import '../widgets/item_icon.dart'; // Ensure this is the correct path

class GodrollHub extends StatefulWidget {
  @override
  _GodrollHubState createState() => _GodrollHubState();
}

class _GodrollHubState extends State<GodrollHub> {
  bool _isSearching = false; // State to toggle search mode
  bool _showFilters = false;
  String _searchQuery = ''; // State to hold the search query

  @override
  Widget build(BuildContext context) {
    var weaponDetailsProvider = Provider.of<WeaponDetailsProvider>(context);
    var weaponDetailsList = weaponDetailsProvider.weaponDetails;

    weaponDetailsList = weaponDetailsList
        .where((weapon) => weapon["randomRoll"] == true)
        .toList();

    var filteredWeaponDetailsList = weaponDetailsList.where((weapon) {
      return weapon['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFF282c34), // Background color like in WeaponRadar
      appBar: _isSearching ? _buildSearchAppBar() : _buildAppBar(),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns
        ),
        itemCount:
            filteredWeaponDetailsList.length, // Number of items in the list
        itemBuilder: (context, index) {
          var weapon = filteredWeaponDetailsList[index];
          return Container(
            child:
                WeaponIcon(associatedWeaponDetails: weapon, showDetails: false),
          ); // Method to build each weapon tile
        },
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
            _searchQuery = query; // Update the search query
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
              _searchQuery = ''; // Clear the search query
            });
          },
        ),
      ],
    );
  }
}

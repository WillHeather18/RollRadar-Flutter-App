import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/weapon_radar.dart';
import '../pages/inventory.dart';
import 'package:provider/provider.dart';
import '../providers/profileprovider.dart';
import '../providers/bungieidprovider.dart';
import '../pages/settings.dart';
import '../pages/godrollhub.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var profileProvider = Provider.of<ProfileProvider>(context);
    var profile = profileProvider.profile;

    var bungieIdProvider = Provider.of<BungieIdProvider>(context);
    var bungieId = bungieIdProvider.bungieId;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(profile['display_name']),
            accountEmail: Text('Bungie ID: ${profile['bungie_id']}'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: profile['icon_url'] != "Default Icon URL"
                  ? Image.network(
                          'https://www.bungie.net${profile['icon_url']}')
                      .image
                  : null,
            ),
            decoration: const BoxDecoration(
              color: Colors.deepPurple, // Example color
            ),
          ),
          ListTile(
            leading:
                const Icon(Icons.radar, color: Colors.black), // Example icon
            title: Text('Weapon Radar',
                style: GoogleFonts.lato(color: Colors.black)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WeaponRadar(bungieID: bungieId)));
            },
          ),
          Divider(color: Colors.grey[800]),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined,
                color: Colors.black), // Example icon
            title:
                Text('Inventory', style: GoogleFonts.lato(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Inventory()));
            },
          ),
          Divider(color: Colors.grey[800]),
          ListTile(
            leading: const Icon(Icons.hub_outlined, color: Colors.black),
            title: Text('Godroll Hub',
                style: GoogleFonts.lato(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GodrollHub()));
            },
          ),
          Divider(color: Colors.grey[800]),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black),
            title:
                Text('Settings', style: GoogleFonts.lato(color: Colors.black)),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
          Divider(color: Colors.grey[800]),
          // Add more ListTile here for other drawer items
        ],
      ),
    );
  }
}

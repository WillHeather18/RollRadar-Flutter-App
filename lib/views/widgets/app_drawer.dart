import 'package:flutter/material.dart';
import 'package:god_roll_app/providers/userprovider.dart';
import 'package:god_roll_app/views/pages/inventory/inventory_page.dart';
import 'package:god_roll_app/views/pages/weapon_radar/weapon_radar_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    var bungieId = userProvider.bungieId;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user.displayName ?? 'User Name'),
            accountEmail: Text('Bungie ID: ${bungieId ?? 'Bungie ID'}'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user.profilePicturePath != "Default Icon URL"
                  ? Image.network(
                          'https://www.bungie.net${user.profilePicturePath}')
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
                  MaterialPageRoute(builder: (context) => const Inventory()));
            },
          ),
          Divider(color: Colors.grey[800]),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black),
            title:
                Text('Settings', style: GoogleFonts.lato(color: Colors.black)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Inventory()));
            },
          ),
          Divider(color: Colors.grey[800]),
          // Add more ListTile here for other drawer items
        ],
      ),
    );
  }
}

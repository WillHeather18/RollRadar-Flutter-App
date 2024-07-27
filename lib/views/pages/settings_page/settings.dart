import 'package:bungie_api/api/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:god_roll_app/providers/userprovider.dart';
import 'package:god_roll_app/views/pages/settings_page/widgets/account_settings.dart';
import 'package:god_roll_app/views/pages/settings_page/widgets/godroll_preferences.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    const double iconSize = 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const SizedBox(
              width: iconSize,
              height: iconSize,
              child: Icon(Icons.account_circle),
            ),
            title: const Text('Account'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AccountSettingsPage(
                          userProvider: userProvider,
                        )),
              );
            },
          ),
          ListTile(
            leading: const SizedBox(
              width: iconSize,
              height: iconSize,
              child: Icon(Icons.notifications),
            ),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Notifications settings
            },
          ),
          ListTile(
            leading: SizedBox(
              width: iconSize,
              height: iconSize,
              child: SvgPicture.asset(
                'assets/icons/hand-cannon.svg',
                // Ensure the SVG icon fits within the bounds
                width: iconSize,
                height: iconSize,
              ),
            ),
            title: const Text('God Roll Preferences'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GodRollPreferences()),
              );
            },
          ),
          ListTile(
            leading: const SizedBox(
              width: iconSize,
              height: iconSize,
              child: Icon(Icons.help),
            ),
            title: const Text('Help and Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Help and Support settings
            },
          ),
          ListTile(
            leading: const SizedBox(
              width: iconSize,
              height: iconSize,
              child: Icon(Icons.info),
            ),
            title: const Text('About'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to About page
            },
          ),
        ],
      ),
    );
  }
}

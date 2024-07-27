import 'package:flutter/material.dart';
import 'package:god_roll_app/providers/userprovider.dart';
import 'package:intl/intl.dart';

class AccountSettingsPage extends StatefulWidget {
  AccountSettingsPage({super.key, required this.userProvider});

  UserProvider userProvider;

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final userData = widget.userProvider.user;

    String dateString = userData.firstAccess ?? '';
    DateTime dateTime = DateTime.parse(dateString);
    int year = dateTime.year;
    String month = DateFormat('MMMM').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 150,
              child: Image.network(
                'https://bungie.net${userData.profilePicturePath}',
              ),
            ),
            Text(userData.displayName ?? '',
                style: const TextStyle(fontSize: 24)),
            Text('Joined: $month ${year.toString()}',
                style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

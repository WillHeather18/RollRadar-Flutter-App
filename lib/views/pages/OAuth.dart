import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:god_roll_app/providers/userprovider.dart';
import 'package:god_roll_app/views/pages/loading_page/loading_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> authenticateWithBungie() async {
    UserProvider userProvider = Provider.of(context, listen: false);
    const String authUrl = 'https://home-jwrvpx7udq-uc.a.run.app';

    print('Starting authentication process...');

    try {
      print('Sending authentication request to $authUrl');
      final result = await FlutterWebAuth2.authenticate(
          url: authUrl, callbackUrlScheme: "rollradar");

      print('Received response from server: $result');

      Uri uri = Uri.parse(result);

      String token =
          uri.queryParameters['access_token']?.replaceAll(' ', '+') ??
              'No token';
      String bungieId = uri.queryParameters['bungie_id'] ?? 'No membership ID';
      String membershipType =
          uri.queryParameters['membership_type'] ?? 'No membership type';
      String destinyMembershipId =
          uri.queryParameters['destiny_membership_id'] ??
              'No destiny membership ID';

      userProvider.setBungieId(bungieId);
      userProvider.setMembershipType(membershipType);
      userProvider.setMembershipType(destinyMembershipId);

      print('Parsed token from response: $token');
      print('Authentication successful with bungie_id: $bungieId');

      if (bungieId != 'No membership ID') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Destiny2LoadingScreen(
              bungieId: bungieId,
              membershipType: membershipType,
              destinyMembershipId: destinyMembershipId,
              accessToken: token,
            ),
          ),
        );
      }
    } catch (e) {
      print('Caught an exception during authentication: $e');
      print('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authenticateWithBungie();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor:
                Colors.deepPurple[800], // Dark purple button background
            backgroundColor: Colors.deepPurple[100], // Light purple text color
            shadowColor: Colors.deepPurple[900], // Shadow color for elevation
            elevation: 10, // Providing some depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Soften the edges a bit
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 30, vertical: 15), // Padding inside the button
          ),
          child: const Text(
            'Authenticate with Bungie.Net',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2, // Adding some spacing between letters
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[900], // Dark background for Destiny 2 theme
    );
  }
}

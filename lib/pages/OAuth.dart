import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../pages/loadingscreen.dart';
import '../providers/bungieidprovider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> authenticateWithBungie() async {
    const String authUrl = 'https://rollradaroauth.azurewebsites.net';

    print('Starting authentication process...');

    var bungieIdProvider =
        Provider.of<BungieIdProvider>(context, listen: false);

    try {
      print('Sending authentication request to $authUrl');
      final result = await FlutterWebAuth2.authenticate(
          url: authUrl, callbackUrlScheme: "rollradar");

      print('Received response from server: $result');

      Uri uri = Uri.parse(result);

      String token = uri.queryParameters['access_token'] ?? 'No token';
      String bungie_id = uri.queryParameters['bungie_id'] ?? 'No membership ID';

      bungieIdProvider.setBungieId(bungie_id);

      print('Parsed token from response: $token');
      print('Authentication successful with bungie_id: $bungie_id');

      if (bungie_id != 'No membership ID') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Destiny2LoadingScreen(
              bungieId: bungie_id,
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
          child: Text(
            'Authenticate with Bungie.Net',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2, // Adding some spacing between letters
            ),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor:
                Colors.deepPurple[800], // Dark purple button background
            backgroundColor: Colors.deepPurple[100], // Light purple text color
            shadowColor: Colors.deepPurple[900], // Shadow color for elevation
            elevation: 10, // Providing some depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Soften the edges a bit
            ),
            padding: EdgeInsets.symmetric(
                horizontal: 30, vertical: 15), // Padding inside the button
          ),
        ),
      ),
      backgroundColor: Colors.grey[900], // Dark background for Destiny 2 theme
    );
  }
}

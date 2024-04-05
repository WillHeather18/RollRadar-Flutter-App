import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../providers/weaponsprovider.dart';
import '../providers/profileprovider.dart';
import '../providers/weapondetailsprovider.dart';
import '../providers/godrollsprovider.dart';
import '../providers/perkdetailsprovider.dart';
import '../providers/characterdetailsprovider.dart';
import '../providers/bungieidprovider.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../pages/weapon_radar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Destiny2LoadingScreen extends StatefulWidget {
  final String bungieId;

  Destiny2LoadingScreen({required this.bungieId});

  @override
  _Destiny2LoadingScreenState createState() => _Destiny2LoadingScreenState();
}

class _Destiny2LoadingScreenState extends State<Destiny2LoadingScreen> {
  String? _token;
  bool _isLoading = true; // Add a loading state
  bool _isAdReady = false; // To track if the ad is read
  String membershipId = '';
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    initializeApp();
  }

  // This method initializes app data and Firebase Messaging
  void initializeApp() async {
    await requestNotificationPermissions();

    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        _token = token;
      });
    });

    await fetchData(); // Make sure all data is loaded before showing ads
    _loadInterstitialAd(); // Load the ad after fetching data
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // test ad
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          setState(() {
            _isAdReady = true; // Ad is ready to be shown
          });
          if (!_isLoading) {
            // Check if loading is completed
            _showInterstitialAd();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          if (!_isLoading) {
            // Proceed if loading is done but ad failed
            navigateToNextScreen();
          }
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          navigateToNextScreen();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          navigateToNextScreen();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      navigateToNextScreen(); // If the ad is not ready, proceed to next screen
    }
  }

  Future<void> requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> fetchData() async {
    var membershipId = widget.bungieId;
    try {
      DateTime start = DateTime.now();
      final response = await http.get(Uri.parse(
          'https://rollradaroauth.azurewebsites.net/getRollRadarDetails/$membershipId'));

      print(
          'Time taken for getAllData: ${DateTime.now().difference(start).inMilliseconds} ms');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Set the data in providers
        Provider.of<WeaponsProvider>(context, listen: false)
            .setWeapons(jsonResponse['all_weapons']['weapons']);
        Provider.of<ProfileProvider>(context, listen: false)
            .setProfile(jsonResponse['profile']);
        Provider.of<GodRollsProvider>(context, listen: false)
            .setGodRolls(jsonResponse['god_rolls']);
        Provider.of<WeaponDetailsProvider>(context, listen: false)
            .setWeaponDetails(jsonResponse['weapon_details']);
        Provider.of<PerkDetailsProvider>(context, listen: false)
            .setPerkDetails(jsonResponse['weapon_perks']);
        Provider.of<CharacterDetailsProvider>(context, listen: false)
            .setCharacterDetails(jsonResponse['character_details']);
        // Add any additional providers that you need to update based on the fetched data
      } else {
        print('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during data fetching: $e');
    } finally {
      // After data fetching is done or failed, check if the ad is ready and loading is completed
      setState(() {
        _isLoading = false; // Loading is done
        if (_isAdReady && !_isLoading) {
          _showInterstitialAd();
        } else if (!_isAdReady) {
          navigateToNextScreen();
        }
      });
    }
  }

  void navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WeaponRadar(bungieID: widget.bungieId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the theme data from the current context to use for colors
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900], // Dark background for Destiny 2 theme
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Loading Guardians...',
                style: TextStyle(
                  color: Colors
                      .white, // A color that hints at in-game elements like Arc energy
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Roboto', // Or any futuristic-looking font available
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(10),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.cyan), // Progress indicator in cyan
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}

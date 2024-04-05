// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '../providers/weaponsprovider.dart';
import '../providers/profileprovider.dart';
import '../providers/weapondetailsprovider.dart';
import '../providers/godrollsprovider.dart';
import '../providers/perkdetailsprovider.dart';
import '../providers/characterdetailsprovider.dart';
import '../providers/bungieidprovider.dart';
import '../pages/OAuth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Define a top-level named handler outside of your class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler before the app is run
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Check for the initial message that launched the app
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Handle the initial message here if your app was terminated when the message was received
    print("Initial message: ${initialMessage.notification?.title}");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeaponsProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => WeaponDetailsProvider()),
        ChangeNotifierProvider(create: (context) => GodRollsProvider()),
        ChangeNotifierProvider(create: (context) => PerkDetailsProvider()),
        ChangeNotifierProvider(create: (context) => CharacterDetailsProvider()),
        ChangeNotifierProvider(create: (context) => BungieIdProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    // Use _isLoading to determine what to display
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Display main content after loading
    );
  }
}

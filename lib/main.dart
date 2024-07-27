// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:god_roll_app/providers/destinyperkprovider.dart';
import 'package:god_roll_app/providers/destinyweaponprovider.dart';
import 'package:god_roll_app/providers/userprovider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import '../providers/profileprovider.dart';
import 'providers/destinycharacterprovider.dart';
import 'views/pages/OAuth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Define a top-level named handler outside of your class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Attempting to load .env file...");

  try {
    await dotenv.load(fileName: ".env");
    print(".env file loaded successfully.");
  } catch (e) {
    print("Failed to load .env file: $e");
  }

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

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

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? storedApiKey = await secureStorage.read(key: 'apiKey');
  if (storedApiKey == null) {
    String apiKey = dotenv.env['API_KEY'] ?? '';
    if (apiKey.isNotEmpty) {
      await secureStorage.write(key: 'apiKey', value: apiKey);
    }
  }
  String? storedOauthClientId = await secureStorage.read(key: 'oauthClientId');
  if (storedOauthClientId == null) {
    String oauthClientId = dotenv.env['OAUTH_CLIENT_ID'] ?? '';
    if (oauthClientId.isNotEmpty) {
      await secureStorage.write(key: 'oauthClientId', value: oauthClientId);
    }
  }
  String? storedOauthClientSecret =
      await secureStorage.read(key: 'oauthClientSecret');
  if (storedOauthClientSecret == null) {
    String oauthClientSecret = dotenv.env['OAUTH_CLIENT_SECRET'] ?? '';
    if (oauthClientSecret.isNotEmpty) {
      await secureStorage.write(
          key: 'oauthClientSecret', value: oauthClientSecret);
    }
  }
  //debugPaintSizeEnabled = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DestinyWeaponProvider>(
            create: (context) => DestinyWeaponProvider()),
        ChangeNotifierProvider<DestinyProfileProvider>(
            create: (context) => DestinyProfileProvider()),
        ChangeNotifierProvider<DestinyCharacterProvider>(
            create: (context) => DestinyCharacterProvider()),
        ChangeNotifierProvider<DestinyPerkProvider>(
            create: (context) => DestinyPerkProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider()),
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
      theme: ThemeData(
        fontFamily: 'NeueHaasDisplay',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400),
          displayLarge: TextStyle(fontWeight: FontWeight.w300),
          displayMedium: TextStyle(fontWeight: FontWeight.w300),
          displaySmall: TextStyle(fontWeight: FontWeight.w300),
          headlineMedium: TextStyle(fontWeight: FontWeight.w300),
          headlineSmall: TextStyle(fontWeight: FontWeight.w300),
          titleLarge: TextStyle(fontWeight: FontWeight.w300),
          titleMedium: TextStyle(fontWeight: FontWeight.w300),
          titleSmall: TextStyle(fontWeight: FontWeight.w300),
          bodySmall: TextStyle(fontWeight: FontWeight.w300),
          labelLarge: TextStyle(fontWeight: FontWeight.w300),
          labelSmall: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Display main content after loading
    );
  }
}

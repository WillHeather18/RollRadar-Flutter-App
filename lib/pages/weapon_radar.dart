import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:god_roll_app/widgets/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../providers/weapondetailsprovider.dart';
import 'package:provider/provider.dart';
import '../providers/perkdetailsprovider.dart';
import '../providers/godrollsprovider.dart';
import '../pages/detail_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/item_icon.dart';
import 'package:http/http.dart' as http;
import '../widgets/radar_background.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WeaponRadar extends StatefulWidget {
  final String bungieID;

  const WeaponRadar({Key? key, required this.bungieID}) : super(key: key);

  @override
  _WeaponRadarState createState() => _WeaponRadarState();
}

class _WeaponRadarState extends State<WeaponRadar>
    with SingleTickerProviderStateMixin {
  IO.Socket? socket;
  List<dynamic> _latestWeapons =
      []; // List to hold weapons dynamically updated from WebSocket
  late AnimationController _animationController;
  late Animation<double> _animation;
  BannerAd? _bannerAd;

  Stream<bool> connectionStatusStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      if (socket != null) {
        // Check if socket is initialized
        yield socket!.connected;
      } else {
        yield false;
      }
    }
  }

  List<Map<String, dynamic>> getPerkDetailsForWeapon(
      List<dynamic> socketHashes, List<dynamic> perkDetailsList) {
    List<Map<String, dynamic>> perks = [];
    for (var socketHash in socketHashes) {
      var perkDetail = perkDetailsList.firstWhere(
        (perk) => perk['hash'] == socketHash,
        orElse: () => null,
      );
      if (perkDetail != null) {
        perks.add(perkDetail);
      }
    }
    return perks;
  }

  void getLatestWeapons() async {
    var response = await http.get(Uri.parse(
        'https://rollradaroauth.azurewebsites.net/getLatestWeapons/${widget.bungieID}'));
    var decodedResponse = json.decode(response.body);

    List<dynamic> latestWeapons;
    if (decodedResponse is List) {
      // If the decoded response is a list, use it directly
      latestWeapons = decodedResponse;
    } else if (decodedResponse is Map) {
      // If the decoded response is a map, extract the list from it (assuming 'weapons' is the key for the list)
      latestWeapons = decodedResponse['weapons'] ?? [];
    } else {
      print('Unexpected data format');
      latestWeapons = [];
    }

    if (latestWeapons.isEmpty) {
      print('No weapons found for user');
    } else {
      print('Weapons found for user');
    }

    setState(() {
      _latestWeapons = latestWeapons;
    });

    connectToSocket(); // Ensuring socket is connected after getting weapons
  }

  void connectToSocket() {
    final String connectionUrl =
        'https://weaponlist.azurewebsites.net?bungieID=${widget.bungieID}';

    socket = IO.io(connectionUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.onConnect((_) {
      print('Connected to WebSocket');
    });

    socket!.on('weapon_change', (data) {
      try {
        final Map<String, dynamic> changeData = json.decode(data);
        if (changeData.containsKey('fullDocument')) {
          final Map<String, dynamic> weaponData = changeData['fullDocument'];
          if (weaponData.containsKey('weapons')) {
            final List<dynamic> weapons = weaponData['weapons'];
            if (weapons.isNotEmpty) {
              setState(() {
                _latestWeapons.insert(0, weapons.last);
                print("Received new weapon data");
              });
            } else {
              print("'weapons' array is empty");
            }
          } else {
            print("Received 'fullDocument' does not contain 'weapons'");
          }
        } else {
          print("Received data does not contain 'fullDocument'");
        }
      } catch (e) {
        print('Error processing weapon data: $e');
      }
    });

    socket!.connect();
  }

  @override
  void initState() {
    super.initState();
    _initBannerAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLatestWeapons();
    });

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.5,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCirc);
  }

  void _initBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3312492533170432/1565277159', // Test ad unit ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    var weaponDetailsProvider = Provider.of<WeaponDetailsProvider>(context);
    var weaponDetailsList = weaponDetailsProvider.weaponDetails;

    var godRollsProvider = Provider.of<GodRollsProvider>(context);
    var godRollsList = godRollsProvider.godRolls;

    return Scaffold(
      backgroundColor: const Color(0xFF282c34),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0f0f23),
        title: Text(
          'Weapon Radar',
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: connectionStatusStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withAlpha(
                                  150), // Adjust the alpha for intensity
                              spreadRadius: _animation.value *
                                  5, // Adjust the spread radius
                              blurRadius: _animation.value *
                                  5, // Adjust the blur radius
                            ),
                          ],
                        ),
                        height: 10.0 + (_animation.value * 5), // Size animation
                        width: 10.0 + (_animation.value * 5), // Size animation
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SvgPicture.asset(
              'assets/icons/radar_logo.svg',
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const RadarSweep(
              imageUrl:
                  'https://user-images.githubusercontent.com/58719230/218909229-67867fec-6f4a-43fb-bfc3-33d6bc42ae2e.png'),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: ListView.builder(
                itemCount: _latestWeapons.length,
                padding: EdgeInsets.only(
                    bottom: _bannerAd?.size.height.toDouble() ?? 50.0),
                itemBuilder: (context, index) {
                  var weapon = _latestWeapons[index];
                  var associatedWeaponDetails = weaponDetailsList.firstWhere(
                    (element) => element['id'] == weapon['weaponHash'],
                    orElse: () => <String, dynamic>{},
                  );

                  final godroll = godRollsList.firstWhere(
                    (godroll) => godroll['weaponHash'] == weapon['weaponHash'],
                    orElse: () => <String, dynamic>{},
                  );

                  // Fetch the perk details for this weapon
                  var perkDetailsList =
                      Provider.of<PerkDetailsProvider>(context).perkDetails;
                  var weaponPerks = getPerkDetailsForWeapon(
                      weapon['socketHashes'], perkDetailsList);

                  return Container(
                    height: 100,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(weapon: weapon),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Weapon icon
                            Column(
                              children: [
                                Container(
                                  height: 75,
                                  width: 75,
                                  child: WeaponIcon(
                                    weapon: weapon,
                                    associatedWeaponDetails:
                                        associatedWeaponDetails,
                                    showDetails: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                width:
                                    10), // Add some space between weapon icon and perks
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  associatedWeaponDetails['name'],
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                    height:
                                        5), // Add some space between weapon name and perks
                                Wrap(
                                  spacing: 4.0,
                                  children: List<Widget>.generate(
                                      weaponPerks.length, (index) {
                                    var perk = weaponPerks[index];
                                    bool _isGodroll = false;
                                    List<String> testList = [
                                      "godroll1",
                                      "godroll2"
                                    ];
                                    var socket_details =
                                        godroll['sockets_details'];

                                    if (socket_details != null) {
                                      print(
                                          'Type of godroll: ${socket_details.length}');
                                    } else {
                                      print('socket_details is null');
                                    }

                                    return Image.network(
                                      "https://www.bungie.net${perk['displayProperties']['icon']}",
                                      width: 40, // Adjust size as needed
                                      height: 40, // Adjust size as needed
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
      drawer: AppDrawer(),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    socket?.disconnect();
    _animationController.dispose(); // Don't forget to dispose of the controller
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:god_roll_app/services/god-roll-service.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/character_selection.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/weapon_info_header.dart';
import 'package:god_roll_app/models/full_item.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/statspanel.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/perktile.dart';
import 'package:god_roll_app/views/pages/detail_page/widgets/godrollpanel.dart';

class DetailPage extends StatefulWidget {
  final FullItem weapon;

  DetailPage({required this.weapon});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _godRoll;
  late bool isRandomRoll;

  @override
  void initState() {
    super.initState();
    isRandomRoll =
        widget.weapon.manifestData!.displaySource!.contains("Random Perks");
    _tabController = TabController(length: isRandomRoll ? 2 : 3, vsync: this);
    _fetchGodRoll();
  }

  Future<void> _fetchGodRoll() async {
    GodRollService godRollService = GodRollService();
    final godRoll =
        await godRollService.getGodRoll(widget.weapon.item.itemHash.toString());
    if (mounted) {
      setState(() {
        _godRoll = godRoll;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0f0f23), Color(0xFF282c34)],
              ),
            ),
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            children: [
              WeaponInfoHeader(weapon: widget.weapon),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.deepPurple,
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.white,
                tabs: isRandomRoll
                    ? [
                        const Tab(text: 'Details'),
                        const Tab(text: 'God Rolls'),
                      ]
                    : [
                        const Tab(text: 'Details'),
                        const Tab(text: 'God Rolls'),
                        const Tab(text: 'Stats'),
                      ],
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: isRandomRoll
                            ? [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 75),
                                  child: SingleChildScrollView(
                                    child: PerksPanel(
                                      weapon: widget.weapon,
                                      godroll: _godRoll!,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 75),
                                  child: SingleChildScrollView(
                                    child: GodRollPanel(
                                      weapon: widget.weapon,
                                      godroll: _godRoll,
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 75),
                                  child: SingleChildScrollView(
                                    child: PerksPanel(
                                      weapon: widget.weapon,
                                      godroll: _godRoll,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 75),
                                  child: SingleChildScrollView(
                                    child: GodRollPanel(
                                      weapon: widget.weapon,
                                      godroll: _godRoll,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 75),
                                  child: StatsPanel(weapon: widget.weapon),
                                ),
                              ],
                      ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CharacterSelectionPanel(
              weapon: widget.weapon,
              isMovingWeapon: false,
              isEquippingWeapon: false,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

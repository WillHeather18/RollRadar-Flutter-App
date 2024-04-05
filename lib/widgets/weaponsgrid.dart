import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/item_icon.dart';
import '../widgets/starrating.dart';
import '../pages/detail_page.dart';
import 'package:provider/provider.dart';
import '../providers/weapondetailsprovider.dart';
import '../providers/weaponsprovider.dart';

class WeaponWidget extends StatefulWidget {
  final List<dynamic> filteredWeapons;
  final double adHeight;

  WeaponWidget({required this.filteredWeapons, this.adHeight = 0});

  @override
  _WeaponWidgetState createState() => _WeaponWidgetState(
      filteredWeapons: this.filteredWeapons, adHeight: this.adHeight);
}

class _WeaponWidgetState extends State<WeaponWidget> {
  List<dynamic> _primaryWeapons = [];
  List<dynamic> _secondaryWeapons = [];
  List<dynamic> _powerWeapons = [];

  List<dynamic> filteredWeapons;
  double adHeight;

  _WeaponWidgetState({required this.filteredWeapons, required this.adHeight});

  @override
  void initState() {
    super.initState();
    // Call organizeWeapons here to ensure your weapons are organized
    // right after the widget is initialized.
    organizeWeapons();
  }

  @override
  void didUpdateWidget(covariant WeaponWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filteredWeapons != widget.filteredWeapons) {
      filteredWeapons = widget.filteredWeapons;
      organizeWeapons(); // Reorganize weapons based on the new list.
    }
  }

  void organizeWeapons() {
    print("Organizing weapons");
    print(filteredWeapons.length);

    var weaponDetailsList =
        Provider.of<WeaponDetailsProvider>(context, listen: false)
            .weaponDetails;

    _primaryWeapons = filteredWeapons.where((weapon) {
      var details = weaponDetailsList.firstWhere(
          (details) => details['id'] == weapon['weaponHash'],
          orElse: () => null);
      return details != null && details['weaponSlot'] == 'Primary';
    }).toList();

    _secondaryWeapons = filteredWeapons.where((weapon) {
      var details = weaponDetailsList.firstWhere(
          (details) => details['id'] == weapon['weaponHash'],
          orElse: () => null);
      return details != null && details['weaponSlot'] == 'Secondary';
    }).toList();

    _powerWeapons = filteredWeapons.where((weapon) {
      var details = weaponDetailsList.firstWhere(
          (details) => details['id'] == weapon['weaponHash'],
          orElse: () => null);
      return details != null && details['weaponSlot'] == 'Heavy';
    }).toList();

    print('Primary Weapons: ${_primaryWeapons.length}');
    print('Secondary Weapons: ${_secondaryWeapons.length}');
    print('Power Weapons: ${_powerWeapons.length}');
  }

  SliverGrid _createWeaponSlotGrid(List<dynamic> weapons) {
    var weaponDetailsList =
        Provider.of<WeaponDetailsProvider>(context).weaponDetails;
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var weapon = weapons[index];
          var associatedWeaponDetails = weaponDetailsList.firstWhere(
            (weaponDetails) => weaponDetails['id'] == weapon['weaponHash'],
            orElse: () => null,
          );

          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailPage(weapon: weapon)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                WeaponIcon(
                    weapon: weapon,
                    associatedWeaponDetails: associatedWeaponDetails,
                    showDetails: true),
                StarRating(fraction: weapon['score'].toString(), size: 18),
              ],
            ),
          );
        },
        childCount: weapons.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1 / 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("building weapon widget");
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<WeaponsProvider>(context, listen: false)
            .refreshWeapons(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weapons refreshed',
                style: GoogleFonts.roboto(color: Colors.white)),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: CustomScrollView(
        slivers: <Widget>[
          if (_primaryWeapons.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Kinetic',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _createWeaponSlotGrid(_primaryWeapons),
          ],
          if (_secondaryWeapons.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Energy',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _createWeaponSlotGrid(_secondaryWeapons),
          ],
          if (_powerWeapons.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Power',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _createWeaponSlotGrid(_powerWeapons),
          ],
          SliverToBoxAdapter(
            child: SizedBox(
              height: adHeight,
            ),
          )
        ],
      ),
    );
  }
}

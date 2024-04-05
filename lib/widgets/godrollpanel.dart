import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/perkdetailsprovider.dart';

class GodRollPanel extends StatefulWidget {
  final Map<String, dynamic> weapon;
  final List<dynamic> godrolls;

  const GodRollPanel({Key? key, required this.weapon, required this.godrolls})
      : super(key: key);

  @override
  _GodRollPanelState createState() => _GodRollPanelState();
}

class _GodRollPanelState extends State<GodRollPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0, end: widget.weapon['total_percentage'] / 100)
            .animate(_controller)
          ..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perkDetailsProvider = Provider.of<PerkDetailsProvider>(context);
    final perkDetailsList = perkDetailsProvider.perkDetails;

    final godroll = widget.godrolls.firstWhere(
      (godroll) => godroll['weaponHash'] == widget.weapon['weaponHash'],
      orElse: () => <String, dynamic>{},
    );

    final List<dynamic> weaponSocketHashes = widget.weapon['socketHashes'];

    final List<dynamic> weaponSocketHashesNames =
        weaponSocketHashes.map((socketHash) {
      final perkDetail = perkDetailsList.firstWhere(
        (perkDetail) => perkDetail['hash'] == socketHash,
        orElse: () => null,
      );
      return perkDetail != null ? perkDetail['displayProperties']['name'] : '';
    }).toList();

    print(weaponSocketHashesNames);
    if (godroll['sockets_details'] != null &&
        godroll['sockets_details'].length > 0) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFda3e52),
            secondary: Color(0xFFf0c330),
          ),
        ),
        child: ExpansionTile(
          backgroundColor: const Color(0xFF1f2233),
          title: Text(
            "Community God Rolls",
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
          ),
          onExpansionChanged: (bool expanded) {
            if (expanded) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          children: <Widget>[
            const SizedBox(height: 10),
            SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        widget.weapon['total_percentage'].toString() + "%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) => Container(
                          height: 15,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white60, width: 2),
                          ),
                          child: LinearProgressIndicator(
                            value: _animation.value,
                            color: Colors.lightBlue,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      godroll['sockets_details'].length,
                      (i) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          godroll['sockets_details'][i].length,
                          (j) {
                            final socketHash = godroll['sockets_details'][i][j]
                                    ["socketHash"]
                                .toString();
                            final perkDetail = perkDetailsList.firstWhere(
                              (perk) => perk['hash'].toString() == socketHash,
                              orElse: () => null,
                            );
                            return Row(
                              children: [
                                if (perkDetail != null &&
                                    perkDetail['displayProperties']['hasIcon'])
                                  Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Image.network(
                                            "https://bungie.net${perkDetail['displayProperties']['icon']}",
                                            width: 60,
                                            height: 60,
                                          ),
                                          if (weaponSocketHashesNames.contains(
                                              godroll['sockets_details'][i][j]
                                                  ['name']))
                                            const Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 20,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        godroll['sockets_details'][i][j]
                                            ["percentage"],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

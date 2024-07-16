import 'package:flutter/material.dart';
import 'package:god_roll_app/services/loading_service.dart';
import 'package:god_roll_app/views/pages/inventory/inventory_page.dart';

class Destiny2LoadingScreen extends StatefulWidget {
  final String bungieId;
  final String membershipType;
  final String destinyMembershipId;
  final String accessToken;

  const Destiny2LoadingScreen({
    super.key,
    required this.bungieId,
    required this.membershipType,
    required this.destinyMembershipId,
    required this.accessToken,
  });

  @override
  _Destiny2LoadingScreenState createState() => _Destiny2LoadingScreenState();
}

class _Destiny2LoadingScreenState extends State<Destiny2LoadingScreen> {
  String loadingMessage = 'Loading Profile Data...';
  bool _isMounted = false;
  bool _isLoading = true;
  bool _isInitialized = false;
  LoadingService? _loadingService;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadingService = LoadingService(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeApp();
      _isInitialized = true;
    }
  }

  void _initializeApp() async {
    await _loadingService?.initializeApp(
      bungieId: widget.bungieId,
      membershipType: widget.membershipType,
      destinyMembershipId: widget.destinyMembershipId,
      accessToken: widget.accessToken,
      setLoadingMessage: (message) {
        if (_isMounted) {
          setState(() {
            loadingMessage = message;
          });
        }
      },
      setIsLoading: (isLoading) {
        if (_isMounted) {
          setState(() {
            _isLoading = isLoading;
            if (!isLoading) {
              _navigateToNextScreen();
            }
          });
        }
      },
      updateData: (weapons, perks, plugSets) {
        if (_isMounted) {
          // Update data if necessary
        }
      },
    );
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Inventory(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                loadingMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
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
    _isMounted = false;
    super.dispose();
  }
}

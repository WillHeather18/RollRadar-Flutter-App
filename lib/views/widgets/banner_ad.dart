import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  static BannerAd? bannerAd;
  static double get bannerAdHeight => bannerAd?.size.height.toDouble() ?? 50.0;

  static Future<void> initBannerAd() async {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3312492533170432/1565277159',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          // Ad is loaded, now it can be displayed
        },
        onAdFailedToLoad: (ad, error) {
          // Handle ad load failure
          ad.dispose();
        },
      ),
    );

    // Load the ad
    await bannerAd!.load();
  }

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  bool _isAdLoaded = false; // State to track if ad is loaded

  @override
  void initState() {
    super.initState();
    BannerAdWidget.initBannerAd().then((_) {
      if (mounted) {
        setState(() {
          _isAdLoaded = true; // Set state to indicate ad is loaded
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded && BannerAdWidget.bannerAd != null
        ? Container(
            width: BannerAdWidget.bannerAd!.size.width.toDouble(),
            height: BannerAdWidget.bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: BannerAdWidget.bannerAd!),
          )
        : SizedBox.shrink();
  }
}

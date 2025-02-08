import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:etiguette/screen/about_pages/about_us.dart';
import 'package:etiguette/screen/feedback/feedback_page.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  BannerAd? _bannerAd;

  final String adUnitId = keys;

  @override
  void initState() {
    super.initState();

    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Title of the app
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          "App Settings",
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //logo of the Screen
          Image.asset(
            "assets/newlogo.png",
            width: 184,
            height: 145,
          ),
          //Other App Options They Open Separate Screens when We clicked any one option
          // ListTile(
          //   onTap: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (builder) => ShowAllEvents()));
          //   },
          //   leading: Icon(
          //     Icons.dashboard,
          //     color: textColor,
          //   ),
          //   title: Text(
          //     "My Events",
          //     style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
          //   ),
          //   trailing: Icon(
          //     Icons.arrow_forward_ios,
          //     color: textColor,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Divider(
          //     color: textColor.withOpacity(.6),
          //   ),
          // ),
          // ListTile(
          //   leading: Icon(
          //     Icons.person,
          //     color: textColor,
          //   ),
          //   title: Text(
          //     "Invite Friends",
          //     style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
          //   ),
          //   trailing: Icon(
          //     Icons.arrow_forward_ios,
          //     color: textColor,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Divider(
          //     color: textColor.withOpacity(.6),
          //   ),
          // ),
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => FeedBackPage()));
            },
            leading: Icon(
              Icons.feedback,
              color: textColor,
            ),
            title: Text(
              "Give Feedback",
              style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: textColor,
            ),
          ),

          // ListTile(
          //   onTap: () {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (builder) => PaymentMethod()));
          //   },
          //   leading: Icon(
          //     Icons.payment,
          //     color: textColor,
          //   ),
          //   title: Text(
          //     "Subscribe!",
          //     style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
          //   ),
          //   trailing: Icon(
          //     Icons.arrow_forward_ios,
          //     color: textColor,
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(
              color: textColor.withOpacity(.6),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (builder) => AboutUs()));
            },
            leading: Icon(
              Icons.info,
              color: textColor,
            ),
            title: Text(
              "About",
              style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: textColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(
              color: textColor.withOpacity(.6),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _bannerAd == null
                  ? Container()
                  : Container(
                      height: AdSize.banner.height.toDouble(),
                      width: AdSize.banner.width.toDouble(),
                      child: AdWidget(ad: _bannerAd!)),
            ),
          ),
        ],
      ),
    );
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    bannerAd.load();
  }
}

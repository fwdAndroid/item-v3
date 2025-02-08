import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/detail/edit_event_detail.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:etiguette/widget/event_card_widget.dart';

class ShowAllEvents extends StatefulWidget {
  const ShowAllEvents({super.key});

  @override
  State<ShowAllEvents> createState() => _ShowAllEventsState();
}

class _ShowAllEventsState extends State<ShowAllEvents> {
  final dbHelper = DatabaseMethod();
  BannerAd? _bannerAd;
  final String adUnitId = keys;
  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "All Events",
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 1.5,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getAllEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text(""));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No contacts available'));
                  } else {
                    List<Map<String, dynamic>> events = snapshot.data!;
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> event = events[index];

                        return EventCardWidget(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => EditEventDetails(
                                        event: event,
                                      )),
                            );
                          },
                          itemCategory: event['itemCategory'],
                          contactName: event['contact_name'],
                          img: event['image']
                              as String, // Replace with actual image path from the event
                          eventText: event[
                              'occasion'], // Replace with actual event name
                          descTitle: event[
                              'description'], // Replace with actual event description
                          categoryText: event[
                              'type'], // Replace with actual event category
                          timeTitle:
                              event['date'], // Replace with actual event time
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),

          // Google Ads Location
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

  /// Loads a banner ad.
  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.fluid,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }
}

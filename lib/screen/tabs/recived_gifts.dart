import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:etiguette/database/database.dart'; // Import your database helper
import 'package:etiguette/screen/detail/edit_event_detail.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:etiguette/widget/event_card_widget.dart';

class Received extends StatefulWidget {
  const Received({Key? key}) : super(key: key);

  @override
  State<Received> createState() => _ReceivedState();
}

class _ReceivedState extends State<Received> {
  final dbHelper = DatabaseMethod(); // Instantiate your database helper
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper
                  .getReceivedEvents(), // Assuming you have a method to fetch received events
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text(""),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No Received gifts available'));
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> receivedEvents = snapshot.data!;

                  return ListView.builder(
                    itemCount: receivedEvents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> event = receivedEvents[index];

                      return EventCardWidget(
                        itemCategory: event['itemCategory'] ?? "",
                        contactName: event['contact_name'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => EditEventDetails(
                                event: event,
                              ),
                            ),
                          );
                        },
                        img: event['image'] as String?,
                        eventText: event['occasion'],
                        descTitle: event['description'],
                        categoryText: event['type'],
                        timeTitle: event[
                            'date'], // Assuming this is a formatted date string
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('No received events found'),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _bannerAd == null
                  ? SizedBox.shrink()
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

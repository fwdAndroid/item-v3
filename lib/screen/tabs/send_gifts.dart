import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/detail/edit_event_detail.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:etiguette/widget/event_card_widget.dart';

class SendGifts extends StatefulWidget {
  const SendGifts({super.key});

  @override
  State<SendGifts> createState() => _SendGiftsState();
}

class _SendGiftsState extends State<SendGifts> {
  BannerAd? _bannerAd;

  final dbHelper = DatabaseMethod(); // Instantiate your database helper
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
                  .getSendEvents(), // Assuming you have a method to fetch received events
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
                  return Center(child: Text('No Send Gifits available'));
                } else if (snapshot.hasData) {
                  List<Map<String, dynamic>> receivedEvents = snapshot.data!;

                  // Sort the events by date in descending order

                  return ListView.builder(
                    itemCount: receivedEvents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> event = receivedEvents[index];

                      return EventCardWidget(
                        itemCategory: event['itemCategory'] ?? "No Category",
                        contactName: event['contact_name'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => EditEventDetails(
                                      event: event,
                                    )),
                          );
                        },
                        img: event['image'] as String?,
                        eventText: event['occasion'],
                        descTitle: event['description'],
                        categoryText: event['type'],
                        timeTitle: event['date'],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      'No received events found',
                      style: TextStyle(color: colorBlack),
                    ),
                  );
                }
              },
            ),
          ),
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

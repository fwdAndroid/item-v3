import 'dart:async';
import 'package:etiguette/widget/contact_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/add/add_event.dart';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';
import 'package:etiguette/screen/detail/edit_event_detail.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ContactDetail extends StatefulWidget {
  final Map<String, dynamic> contact;

  ContactDetail({super.key, required this.contact});

  @override
  State<ContactDetail> createState() => _ContactDetailState();
}

class _ContactDetailState extends State<ContactDetail> {
  final dbHelper = DatabaseMethod();
  BannerAd? _bannerAd;
  final String adUnitId = keys;

  @override
  void initState() {
    super.initState();
    _loadAd();
    calculateGifts(); // Calculate gifts when the widget initializes
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Color textColor = Colors.green; // Default text color for "Harmonious"
  String category = 'Harmonious'; // Default category is "Harmonious"
  int sentPoints = 0;
  int receivedPoints = 0;

  Future<void> calculateGifts() async {
    final sentEvents = await dbHelper.getSendEvent(widget.contact['name']);
    final receivedEvents =
        await dbHelper.getReceivedEvent(widget.contact['name']);

    int tempSentPoints = 0;
    int tempReceivedPoints = 0;

    for (final event in sentEvents) {
      tempSentPoints += calculatePoints(event['itemCategory']);
    }

    for (final event in receivedEvents) {
      tempReceivedPoints += calculatePoints(event['itemCategory']);
    }

    setState(() {
      sentPoints = tempSentPoints;
      receivedPoints = tempReceivedPoints;
      final double receivedPercentage =
          sentPoints == 0 ? 0 : receivedPoints / sentPoints;
      if (sentPoints == 0 && receivedPoints == 0) {
        category = 'Harmonious';
        textColor = Colors.green;
      } else if (sentPoints == 0 && receivedPoints > 0) {
        category = 'Lacking';
        textColor = Colors.orange;
      } else if (sentPoints > 0 && receivedPoints == 0) {
        category = 'Generous';
        textColor = Colors.blue;
      } else if (receivedPercentage < 0.67) {
        category = 'Generous';
        textColor = Colors.blue;
      } else if (receivedPercentage > 1.33) {
        category = 'Lacking';
        textColor = Colors.orange;
      } else {
        category = 'Harmonious';
        textColor = Colors.green;
      }
    });
  }

  int calculatePoints(String? giftType) {
    switch (giftType) {
      case 'micro':
        return 1;
      case 'small':
        return 2;
      case 'medium':
        return 3;
      case 'large':
        return 4;
      case 'huge':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => AddEvents(
                        contactName: widget.contact['name'],
                        contact: widget.contact,
                        category: category,
                      )));
        },
        child: Icon(
          Icons.add,
          color: colorWhite,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => MainDashboard(initialPageIndex: 2)));
          },
        ),
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          widget.contact['name'] ?? '',
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(20)),
                width: 307,
                height: 97,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder(
                        future: dbHelper
                            .getContactEventsCount(widget.contact['name']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("");
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: colorWhite),
                            );
                          }
                          final int eventCount = snapshot.data ?? 0;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Activity",
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: colorWhite,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "$eventCount",
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: colorWhite,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          );
                        }),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$category',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getContactEvents(widget.contact['name']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text(""),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    List<Map<String, dynamic>> events = snapshot.data!;

                    // Sort the events by date in descending order

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.59,
                        child: ListView.builder(
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> event = events[index];
                              return ContactCardWidget(
                                itemCategory: event['itemCategory'] ?? "",
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
                            }),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(color: colorBlack),
                      ),
                    );
                  }
                }),
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
      size: AdSize.fluid,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/detail/edit_event_detail.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:etiguette/widget/event_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  final dbHelper = DatabaseMethod();
  final String adUnitId = keys;
  List<Map<String, dynamic>> events = []; // Declare a list to store events

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    List<Map<String, dynamic>> fetchedEvents =
        await dbHelper.getTopFiveEvents();
    setState(() {
      events = fetchedEvents; // Update state with fetched events
    });
  }

  Future<void> _refreshEvents() async {
    // Fetch updated events and update the state
    List<Map<String, dynamic>> updatedEvents =
        await dbHelper.getTopFiveEvents();
    setState(() {
      events = updatedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: mainColor,
        title: Text(
          "Home Page",
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
                        future: dbHelper.getContactsCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("");
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white),
                            );
                          } else if (snapshot.hasData) {
                            var activeContacts = snapshot.data!;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Contacts",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: colorWhite,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "$activeContacts",
                                  style: GoogleFonts.inter(
                                      fontSize: 30,
                                      color: colorWhite,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          } else {
                            return Text(
                              '0',
                              style: TextStyle(color: colorWhite),
                            );
                          }
                        }),
                    FutureBuilder(
                        future: dbHelper.getEventsCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("");
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: colorWhite),
                            );
                          } else if (snapshot.hasData) {
                            var activeEvents = snapshot.data!;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Active Items",
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: colorWhite,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "$activeEvents",
                                  style: GoogleFonts.inter(
                                      fontSize: 30,
                                      color: colorWhite,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            );
                          } else {
                            return Text(
                              '0',
                              style: TextStyle(color: colorWhite),
                            );
                          }
                        })
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 1.9,
              child: RefreshIndicator(
                onRefresh: _refreshEvents, // Use RefreshIndicator to refresh
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> event = events[index];

                    return EventCardWidget(
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
                      itemCategory: event['itemCategory'],
                    );
                  },
                ),
              ),
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

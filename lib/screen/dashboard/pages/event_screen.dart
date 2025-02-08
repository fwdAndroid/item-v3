import 'dart:typed_data';

import 'package:etiguette/database/database.dart';
import 'package:etiguette/screen/add/add_contacts.dart';
import 'package:etiguette/screen/contact/contact_detail.dart';
import 'package:etiguette/screen/contact/edit_contact.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final dbHelper = DatabaseMethod();
  BannerAd? _bannerAd;

  final String adUnitId = keys;

  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadAllContacts();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAllContacts() async {
    setState(() {
      isLoading = true;
    });
    // Load all contacts at once
    List<Map<String, dynamic>> allContacts = await dbHelper.getAllContacts();
    setState(() {
      contacts = allContacts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => AddContacts()));
        },
        child: Icon(
          Icons.add,
          color: colorWhite,
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: mainColor,
        title: Text(
          "Contacts",
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Main content with contacts list

          Expanded(
            //height: MediaQuery.of(context).size.height / 1.4,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                String type = contact['type'];
                String imagePath =
                    type == 'Romantic' ? 'romantic.png' : 'platonic.png';
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => ContactDetail(contact: contact),
                      ),
                    );
                  },
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: contact['image'] != null
                              ? CircleAvatar(
                                  radius: 30,
                                  backgroundImage: MemoryImage(
                                      contact['image'] as Uint8List),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 30,
                                ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contact['name'] ?? '',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) => EditContact(
                                          contactId: contact['id'],
                                          contactName: contact['name'],
                                          contactNotes: contact['notes'],
                                          contactPhoto: contact['image'],
                                          contactType: contact['type'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text("Edit"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Contact"),
                                          content: Text(
                                              "Are you sure you want to delete this contact?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await dbHelper
                                                    .deleteContactAndEvents(
                                                        contact['id']);
                                                Navigator.of(context).pop();
                                                setState(() {
                                                  contacts.removeAt(index);
                                                });
                                              },
                                              child: Text("Delete"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Image.asset(
                          "assets/$imagePath",
                          height: 50,
                          width: 50,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Display Ad at the bottom if payment not done
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

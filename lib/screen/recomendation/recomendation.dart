import 'dart:convert';

import 'package:etiguette/utils/colors.dart';
import 'package:etiguette/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Recommendation extends StatefulWidget {
  final String description;
  final String contactType;
  final String eventName;
  final Function(String) onAddDescription;
  final String itemCategory;

  const Recommendation({
    super.key,
    required this.description,
    required this.contactType,
    required this.itemCategory,
    required this.eventName,
    required this.onAddDescription,
  });

  @override
  State<Recommendation> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  BannerAd? _bannerAd;
  bool isPaymentDone = false;
  final String adUnitId = keys;
  bool isLoading = true; // Added for loading indicator
  List<Map<String, dynamic>>? recommendations;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          'Recommendation',
          style: GoogleFonts.workSans(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recommendations == null || recommendations!.isEmpty
              ? const Center(child: Text("No recommendations available"))
              : Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (recommendations != null &&
                            recommendations!.isNotEmpty) {
                          final String url = recommendations![0]['link'] ??
                              ''; // First recommendation link
                          if (url.isNotEmpty) {
                            _launchURL(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("No link available")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("No recommendations available")),
                          );
                        }
                      },
                      child: Text(
                        "Gift ideas contain affiliate links, to help generate better gift ideas!",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendations!.length,
                        itemBuilder: (context, index) {
                          final recommendation = recommendations![index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(recommendation['image']),
                              ),
                              title: Text(recommendation['description']),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.add, color: Colors.green),
                                onPressed: () {
                                  widget.onAddDescription(
                                      recommendation['description']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Recommendation Selected")),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              onTap: () =>
                                  _launchURL(recommendation['link'] ?? ''),
                            ),
                          );
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
                    const SizedBox(height: 10),
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

  Future<void> _fetchRecommendations() async {
    final String url = 'https://gifted.phantominteractive.com.au/recommend';
    Map<String, dynamic> requestBody = {
      'relation': widget.contactType,
      'id': Uuid().v4(),
      'description': widget.description,
      'event': widget.eventName,
      'category': widget.itemCategory,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendations =
              List<Map<String, dynamic>>.from(data['recommendations']);
          isLoading = false;
        });
      } else {
        _showError('Failed to fetch recommendations. Try again later.');
      }
    } catch (error) {
      _showError('An error occurred: $error');
    }
  }

  // Launch URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showError('Could not launch URL');
    }
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() => isLoading = false);
  }
}

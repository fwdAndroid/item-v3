import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/screen/tabs/recived_gifts.dart';
import 'package:etiguette/screen/tabs/send_gifts.dart';
import 'package:etiguette/utils/colors.dart';

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        // Screen Title
        appBar: AppBar(
          backgroundColor: mainColor,
          title: Text(
            "Gifts",
            style: GoogleFonts.workSans(
                color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            // Tabbar Properties
            indicatorColor: mainColor,
            labelColor: colorYellow,
            labelStyle: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelColor: colorBlack,
            unselectedLabelStyle: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            //Tabbar Title
            tabs: <Widget>[
              Tab(
                text: "Receive",
              ),
              Tab(
                text: "Send",
              ),
            ],
          ),
        ),
        //TabView Classes They are open  on Different Screens These Screens are called in tab folder inside the screens folder
        body: const TabBarView(
          children: <Widget>[Received(), SendGifts()],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/screen/about_pages/customer_terms.dart';
import 'package:etiguette/screen/about_pages/help_support.dart';
import 'package:etiguette/utils/colors.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Title of the app
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "About",
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //logo of the Screen
          Image.asset(
            "assets/logo.png",
            width: 184,
            height: 145,
          ),
          //Other App Options They Open Separate Screens when We clicked any one option
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => CustomerTerms()));
            },
            title: Text(
              "This App",
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
          ListTile(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => HelpandSupport()));
            },
            title: Text(
              "Help & Support",
              style: GoogleFonts.workSans(fontSize: 16, color: iconColor),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

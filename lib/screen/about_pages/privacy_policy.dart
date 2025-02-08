import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/utils/colors.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.workSans(
              color: colorWhite, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 600,
                  width: 327,
                  child: Text(
                      "Welcome to etiGuette! Please visit https://phantominteractive.com.au/privacy.html for our privacy policy"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

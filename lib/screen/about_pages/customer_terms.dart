import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/utils/colors.dart';

class CustomerTerms extends StatefulWidget {
  const CustomerTerms({super.key});

  @override
  State<CustomerTerms> createState() => _CustomerTermsState();
}

class _CustomerTermsState extends State<CustomerTerms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "Terms of Service",
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
                      "etiGuette will help you track your gifting history with friends and family, as well as suggestion gift ideas appropriate for the occasion. Simply add your contacts and the gifts to be sent and received, etiGuette will assist you with planning and gift choices.\nEach contact will be evaluated for the exchange of gifts received and sent to assist with the balance of gifting frequency and value."),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

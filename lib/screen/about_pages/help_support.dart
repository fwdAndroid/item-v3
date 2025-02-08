import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/utils/colors.dart';

class HelpandSupport extends StatefulWidget {
  const HelpandSupport({super.key});

  @override
  State<HelpandSupport> createState() => _HelpandSupportState();
}

class _HelpandSupportState extends State<HelpandSupport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        title: Text(
          "Help And Support",
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
                  width: 326,
                  child: Text(
                      "Please provide feedback using the built-in feedback tab, alternatively visit our Discord channel https://discord.gg/47efnXGshr for support related queries."),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

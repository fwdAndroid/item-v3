import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/utils/colors.dart';

// Create Complete Widget Details which items are used in the app
class EventCardWidget extends StatelessWidget {
  final String? img;
  final VoidCallback onTap;

  final String eventText;
  final String timeTitle;
  final String descTitle;
  final String categoryText;
  final String itemCategory;

  final String contactName;

  EventCardWidget({
    super.key,
    required this.img,
    required this.onTap,
    required this.eventText,
    required this.contactName,
    required this.descTitle,
    required this.itemCategory,
    required this.categoryText,
    required this.timeTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: colorWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
            side: BorderSide(
              color: colorWhite,
            ),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(contactName),
            Row(
              children: [
                img != null && File(img!).existsSync()
                    ? Image.file(
                        File(img!),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    : Icon(Icons.image, size: 100, color: Colors.white),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventText,
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      timeTitle,
                      style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: lightColor),
                    ),
                    Text(
                      categoryText,
                      style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff50555C)),
                    ),
                    // if (categoryText != 'Receive') // Conditional check
                    Text(
                      itemCategory,
                      style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff50555C)),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        descTitle,
                        style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xff50555C)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

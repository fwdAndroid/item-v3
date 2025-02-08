import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';
import 'package:etiguette/utils/colors.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:etiguette/utils/savebutton.dart';
import 'package:http/http.dart' as http;

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({Key? key}) : super(key: key);

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  TextEditingController descriptionController = TextEditingController();
  double rating = 3;

  bool isLoading = false;

  Future<void> submitFeedback() async {
    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Comment is Required")));
    } else {
      setState(() {
        isLoading = true;
      });
      final String url = 'https://gifted.phantominteractive.com.au/feedback';

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'content': descriptionController.text, //Add your contact here if needed
        'rating': rating.toString(),
      };
      String requestBodyJson = jsonEncode(requestBody);
      try {
        // Send the HTTP POST request
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: requestBodyJson,
        );

        // Check if the request was successful
        if (response.statusCode == 200) {
          setState(() {
            isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => MainDashboard()),
          );
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("FeedBack Send")));
        } else {
          // Handle error here
        }
      } catch (e) {
        print('Failed to send feedback. Error: $e');
        // Handle error here
      }
    }

    // Convert the request body to JSON
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/logo.png",
                width: 184,
                height: 150,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Share your experience in scaling",
              style: GoogleFonts.montserrat(
                  fontSize: 12, fontWeight: FontWeight.bold, color: colorBlack),
            ),
          ),

          // Rate Library is used to send the feedback to the user.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 13),
            child: TextFormField(
              maxLines: 3,
              controller: descriptionController,
              decoration: InputDecoration(
                filled: true,
                hintText: "Add Your Comments",
                fillColor: greyColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => MainDashboard()));
                    // Handle cancel action if needed
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: colorBlack, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 20),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: mainColor,
                        ),
                      )
                    : SaveButton(
                        title: "Submit",
                        onTap: submitFeedback,
                        width: 150,
                        height: 50,
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

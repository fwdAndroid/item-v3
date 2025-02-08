// Import Files
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:etiguette/screen/dashboard/main_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //Timer  After 3 seconds it will automatically moved on Next Screen
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainDashboard())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        // Get Full Width  and Height of the Image
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child:
                    // Image attribute
                    Image.asset("assets/newlogo.png"))
          ],
        ),
      ),
    );
  }
}

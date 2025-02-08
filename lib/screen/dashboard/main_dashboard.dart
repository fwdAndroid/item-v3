import 'package:flutter/material.dart';
import 'package:etiguette/screen/dashboard/pages/app_screen.dart';
import 'package:etiguette/screen/dashboard/pages/event_screen.dart';
import 'package:etiguette/screen/dashboard/pages/gift_screen.dart';
import 'package:etiguette/screen/dashboard/pages/home_screen.dart';
import 'package:etiguette/utils/colors.dart';

class MainDashboard extends StatefulWidget {
  final int initialPageIndex;

  const MainDashboard({Key? key, this.initialPageIndex = 0}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPageIndex; // Initialize with passed index
  }

  // These classes are attached with the bottom Nav bar when we clicked any icon of bottom navigation bar
  // Relevant screen will open
  final List<Widget> _screens = [
    HomeScreen(),
    GiftScreen(),
    EventScreen(),
    AppScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        // Call classes
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        // Set images in bottom Nav Bar from assets folder
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _currentIndex == 0
                  ? Image.asset(
                      "assets/home_yellow.png",
                      height: 25,
                    )
                  : Image.asset(
                      "assets/home_gray.png",
                      height: 25,
                    ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _currentIndex == 1
                  ? Image.asset(
                      "assets/booking_yellow.png",
                      height: 25,
                    )
                  : Image.asset(
                      "assets/booking_grey.png",
                      height: 25,
                    ),
              label: '',
            ),
            BottomNavigationBarItem(
                label: "",
                icon: _currentIndex == 2
                    ? Image.asset(
                        "assets/person_yellow.png",
                        height: 25,
                      )
                    : Image.asset(
                        "assets/person_gray.png",
                        height: 25,
                      )),
            BottomNavigationBarItem(
              label: "",
              icon: _currentIndex == 3
                  ? Image.asset(
                      "assets/event_yellow.png",
                      height: 25,
                    )
                  : Image.asset(
                      "assets/event_gray.png",
                      height: 25,
                    ),
            ),
          ],

          // Applying background color of the bottom Nav Bar
          backgroundColor: colorWhite, // Set your desired background color here
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}

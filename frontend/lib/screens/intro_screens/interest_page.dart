import 'package:flutter/material.dart';
import 'package:frontend/screens/intro_screens/interest_button.dart';
import 'package:frontend/screens/intro_screens/intro_screen_1.dart';
import 'package:frontend/screens/splash_screen.dart';

class InterestPage extends StatelessWidget {
  const InterestPage({super.key});

  final List<String> interests = const [
    "Music",
    "Anchoring",
    "Dance",
    "Photography",
    "Writing",
    "Gaming",
    "Coding",
    "Design",
    "Sports",
    "Reading",
    "Music",
    "Anchoring",
    "Dance",
    "Photography",
    "Writing",
    "Gaming",
    "Coding",
    "Design",
    "Sports",
    "Reading",
    "Music",
    "Anchoring",
    "Dance",
    "Photography",
    "Writing",
    "Gaming",
    "Coding",
    "Design",
    "Sports",
    "Reading",
    "Music",
    "Anchoring",
    "Dance",
    "Photography",
    "Writing",
    "Gaming",
    "Coding",
    "Design",
    "Sports",
    "Reading",
    "Music",
    "Anchoring",
    "Dance",
    "Photography",
    "Writing",
    "Gaming",
    "Coding",
    "Design",
    "Sports",
    "Reading",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => IntroScreen1()));
              },
              icon: Icon(
                Icons.arrow_back,
                size: 28,
              )),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SplashScreen()));
                },
                child: Text(
                  "Skip",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ))
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Whats are your interests?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SaansTrial',
                      fontSize: 30),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "Choose topics you like. You can update them\nanytime from your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(height: 28),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  thickness: 6,
                  radius: Radius.circular(4),

                  //ScrollBar Theme
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: WidgetStateProperty.all(Colors.black),
                        trackColor:
                            WidgetStateProperty.all(Colors.grey.shade300),
                        trackBorderColor:
                            WidgetStateProperty.all(Colors.grey.shade400),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: interests.map((interest) {
                            return InterestButton(
                              labelText: interest,
                              onTouch: () {
                                // Handle interaction
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          width: double.infinity,
          height: 128,
          decoration: BoxDecoration(color: Colors.grey.shade100),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 56),
            child: ElevatedButton(
              onPressed: () {
                // action
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              child: Text(
                "Continue",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ));
  }
}

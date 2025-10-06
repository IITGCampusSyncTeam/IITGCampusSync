import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/intro_screens/intro_screen_3.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 44,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Divider(
                      color: Colors.black,
                      thickness: 4,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100.52,
            ),
            SvgPicture.asset(
              'assets/intro_page_2.svg',
              width: 300.28,
              height: 280.08,
            ),
            SizedBox(
                height:
                    //78.6 //(original length given by the designer)
                    160),
            Text(
              "RSVP and Keep Track\nWith Ease",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'SaansTrial',
                  fontSize: 28),
            ),
            SizedBox(height: 8),
            Text(
              "Save your spot in a tap and stay on top of\nall your upcoming events.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 44,
            ),
            SizedBox(
              width: 328,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => IntroScreen3()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Button color
                  foregroundColor: Colors.white, // Text/Icon color
                  elevation: 5, // Shadow depth
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ), // You can reduce this if height is tight
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100), // Rounded corners
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text(
                  "Next",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

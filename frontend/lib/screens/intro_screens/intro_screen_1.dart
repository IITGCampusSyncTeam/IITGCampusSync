import 'package:flutter/material.dart';
import 'package:frontend/screens/intro_screens/intro_screen_2.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
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
                    flex: 1,
                    child: Divider(
                      color: Colors.black,
                      thickness: 4,
                    ),
                  ),
                  Expanded(
                    flex: 2,
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
            //
            Image.asset('assets/images/intropage1.png',
                width: width * 0.6, height: height * 0.4, fit: BoxFit.contain),

            SizedBox(height: height * 0.06
                //78.6 //(original length given by the designer)
                //144
                ),
            Text(
              "Find Events That\nMatch Your Interests",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontFamily: 'SaansTrial',
                fontSize: width * 0.075,
              ),
            ),
            SizedBox(height: height * 0.01),
            Text(
              "Follow clubs you care about and stay updated\nwith events that matter to you.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: width * 0.043,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: height * 0.06,
            ),
            SizedBox(
              width: width * 0.85,
              height: height * 0.058,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => IntroScreen2()));
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

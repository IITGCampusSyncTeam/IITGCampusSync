import 'package:flutter/material.dart';
import 'package:frontend/screens/splash_screen.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key});

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
                    flex: 3,
                    child: Divider(
                      color: Colors.black,
                      thickness: 4,
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.044,
              //100.52,
            ),
            Image.asset('assets/images/intropage3.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                fit: BoxFit.contain),
            SizedBox(height: height * 0.025
                //78.6 //(original length given by the designer)
                //134
                ),
            Text(
              "Do More With Every\nEvent You Join",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'SaansTrial',
                  fontSize: height * 0.035),
            ),
            SizedBox(height: height * 0.01),
            Text(
              "Set custom reminders track your plans and\nexplore event merch all in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: height * 0.06,
            ),
            SizedBox(
              width: width * 0.85,
              height: height * 0.06,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SplashScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text(
                  "Get Started",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}

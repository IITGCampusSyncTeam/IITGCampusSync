import 'package:flutter/material.dart';

class RsvpInfoSlider extends StatefulWidget {
  @override
  _RsvpInfoSliderState createState() => _RsvpInfoSliderState();
}

class _RsvpInfoSliderState extends State<RsvpInfoSlider> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          builder: (_) => SizedBox(
            height: 600,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(
                    height: 3,
                    thickness: 2,
                    indent: 150,
                    endIndent: 150,
                    color: Color(0xff71717b),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => {
                          Navigator.pop(context)
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Color(0xff27272A),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '52 Students RSVPed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff27272A),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 183,
                      height: 50,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                          backgroundColor: Colors.black,   // button background
                          foregroundColor: Colors.white,   // text + ripple color
                        ),
                        child: Text(
                          "See Insights",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 88,  // elongates horizontally
                      height: 50,  // optional, for taller button
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45),
                          ),
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            "Full List",
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.all(8.0),
                        ),
                        onPressed: () => {
                          // Handle button press
                        },
                        icon: Icon(Icons.file_download_outlined),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.grey[300],
                  thickness: 1,
                )
              ],

            )
          )
        )
      },
      icon: const Icon(Icons.more_horiz,),
      style: IconButton.styleFrom(
        backgroundColor: Colors.grey[200],
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
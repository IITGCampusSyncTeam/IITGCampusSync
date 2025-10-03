import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/screens/org_screens/RSVPIcons.dart';
import 'package:frontend/screens/org_screens/rsvp_info_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({super.key});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  var events;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events == null ? 2 : events.length, // example count
      itemBuilder: (context, index) => _PastEventTile(
        event: events == null ? null : events[index],
      ),
    );
  }

  void initialize() async {
    final pref = await SharedPreferences.getInstance();
    final creatorID = pref.getString('userID');
    final response = await http.get(Uri.parse(
        'https://iitgcampussync.onrender.com/api/events/active-events-by-creator/$creatorID'));
    if (response.statusCode == 200) {
      setState(() {
        events = jsonDecode(response.body);
      });
    }
  }
}

class _PastEventTile extends StatelessWidget {
  const _PastEventTile({required this.event});

  final event;

  @override
  Widget build(BuildContext context) {
    return _PastEventsCard(event: event);
  }
}

class _PastEventsCard extends StatelessWidget {
  const _PastEventsCard({required this.event});

  final event;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
            border: Border.all(color: TextColors.muted)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    topLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    event == null
                        ? 'https://unsplash.com/s/photos/random-person'
                        : event['banner'] ??
                            'https://unsplash.com/s/photos/random-person',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                if (event != null)
                  if (event['dateTime'] >= DateTime.now())
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            width: 48,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  height: 6,
                                  width: 6,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius:
                                          BorderRadius.circular(1000)),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Live',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event == null
                        ? 'Test Title'
                        : event['title'] ?? "Test Title",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.watch_later_outlined,
                        size: 18,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Text(
                        event == null
                            ? 'Test dateTime'
                            : DateFormat('d MMMM').format(
                                        DateTime.parse(event['dateTime'])) ==
                                    ''
                                ? "Test dateTime"
                                : DateFormat('d MMMM')
                                    .format(DateTime.parse(event['dateTime'])),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RSVPIcons(
                  RSVP: event == null ? [] : event['RSVP'] ?? [],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFF6900),
                      ),
                      SizedBox(width: 3.33,),
                      Text(
                        '${event == null ? '0' : event['rating'] ?? '0'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
              color: TextColors.muted,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        // TODO: implement See Insights
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 40,
                        width: (screenWidth - 108),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'See Insight',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      // TODO: Implement More
                    },
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Color(0xFFE4E4E7),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // child: InkWell(
                  //   borderRadius: BorderRadius.circular(999),
                  //   onTap: () {
                  //     // TODO: Implement More
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(7),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(999),
                  //         color: Color(0xFFE4E4E7)),
                  //     child: Icon(
                  //       Icons.more_horiz,
                  //       color: Colors.black,
                  //     ),
                  //   ),
                  // ),
                  child: RsvpInfoSlider(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

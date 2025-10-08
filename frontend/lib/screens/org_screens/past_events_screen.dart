import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/screens/org_screens/RSVPIcons.dart';
import 'package:frontend/screens/org_screens/rsvp_info_slider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastEventsScreen extends StatefulWidget {
  const PastEventsScreen({super.key});

  @override
  State<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends State<PastEventsScreen> {
  dynamic events;

  @override
  void initState() {
    // initialize(); // You can comment this out to use test data
    loadTestData(); // Use this to load hardcoded events
    super.initState();
  }

  void initialize() async {
    final pref = await SharedPreferences.getInstance();
    final creatorID = pref.getString('userID');
    // Corrected the API endpoint to fetch past events
    final response = await http.get(Uri.parse(
        'https://10.0.0.2:3000/api/events/past-events-by-creator/$creatorID'));
    if (response.statusCode == 200) {
      setState(() {
        events = jsonDecode(response.body);
      });
    } else {
      // Handle error or set events to an empty list
      setState(() {
        events = [];
      });
    }
  }

  // New function to load test data
  void loadTestData() {
    setState(() {
      events = [
        {
          "_id": "651b2d4b4a3f5a1bb811c4p1",
          "title": "Post-Hackathon Celebration",
          "description": "A get-together to celebrate the success of our annual hackathon. Food and drinks provided!",
          "dateTime":
          DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
          "venue": "Campus Hub",
          "organizerName": "Coding Club",
          "organizerEmail": "codingclub@iitg.ac.in",
          "banner":
          "https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop",
          "RSVP": ["user1", "user2", "user3", "user4", "user5", "user6"],
          "views": 450,
          "rating": 4.8
        },
        {
          "_id": "651b2d4b4a3f5a1bb811c4p2",
          "title": "Alumni Meet & Greet 2024",
          "description":
          "An evening with our esteemed alumni, sharing their experiences in the industry.",
          "dateTime":
          DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
          "venue": "Conference Hall",
          "organizerName": "Alumni Association",
          "organizerEmail": "alumni@iitg.ac.in",
          "banner":
          "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?q=80&w=2232&auto=format&fit=crop",
          "RSVP": ["userA", "userB", "userC"],
          "views": 670,
          "rating": 4.9
        },
        {
          "_id": "651b2d4b4a3f5a1bb811c4p3",
          "title": "Intro to Graphic Design",
          "description":
          "A beginner-friendly workshop on the fundamentals of graphic design.",
          "dateTime":
          DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
          "venue": "Design Studio",
          "organizerName": "Design Club",
          "organizerEmail": "design@iitg.ac.in",
          "banner": null, // Example with no banner
          "RSVP": [],
          "views": 210,
          "rating": 4.5
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while events are being fetched
    if (events == null) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show a message if there are no past events
    if (events.isEmpty) {
      return const Center(child: Text("No past events found."));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) => _PastEventTile(
        event: events[index],
      ),
    );
  }
}

class _PastEventTile extends StatelessWidget {
  const _PastEventTile({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    return _PastEventsCard(event: event);
  }
}

class _PastEventsCard extends StatelessWidget {
  const _PastEventsCard({required this.event});

  final dynamic event;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Show a shimmer/loading effect if the event data is null
    if (event == null) {
      return const CircularProgressIndicator(); // Or a shimmer effect widget
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
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
                    event['banner'] ??
                        // A placeholder that is more likely to work
                        'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=2070&auto=format&fit=crop',
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
                // Removed the "Live" badge as this is the past events screen
              ],
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    event['title'] ?? "Test Title",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.watch_later_outlined,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        // Simplified date formatting
                        DateFormat('d MMMM yyyy')
                            .format(DateTime.parse(event['dateTime'])),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Added for spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RSVPIcons(
                  RSVP: List<String>.from(event['RSVP'] ?? []),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFFF6900),
                      ),
                      const SizedBox(
                        width: 3.33,
                      ),
                      Text(
                        '${event['rating'] ?? 'N/A'}', // Use N/A for missing rating
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 16, // Adjusted height for better spacing
              color: TextColors.muted,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 16), // Adjusted padding
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
                        child: const Text(
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
                const Padding( // RsvpInfoSlider was causing an overflow
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                  // child: RsvpInfoSlider(), // This widget might not be needed or should be constrained
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

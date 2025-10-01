import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  var Events = null;

  @override
  void initState() {
    INIT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Events == null ? 2 : Events.length, // example count
      itemBuilder: (context, index) => _PastEventTile(
        Event: Events == null ? null : Events[index],
      ),
    );
  }

  void INIT() async {
    final pref = await SharedPreferences.getInstance();
    final creatorID = await pref.getString('userID');
    final response = await http.get(Uri.parse(
        'https://iitgcampussync.onrender.com/api/events/active-events-by-creator/${creatorID}'));
    if (response.statusCode == 200) {
      setState(() {
        Events = jsonDecode(response.body);
      });
    }
  }
}

class _PastEventTile extends StatelessWidget {
  _PastEventTile({super.key, required this.Event});

  final Event;

  @override
  Widget build(BuildContext context) {
    return _PastEventsCard(Event: Event);
  }
}

class _PastEventsCard extends StatelessWidget {
  const _PastEventsCard({super.key, required this.Event});

  final Event;

  @override
  Widget build(BuildContext context) {
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              child: Image.network(
                Event == null
                    ? 'https://unsplash.com/s/photos/random-person'
                    : Event['banner'] ??
                        'https://unsplash.com/s/photos/random-person',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 160,
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
            Container(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              alignment: Alignment.centerLeft,
              child: Text(
                Event == null ? 'Test Title' : Event['title'] ?? "Test Title",
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
                    Event == null
                        ? 'Test dateTime'
                        : DateFormat('d MMMM, h:mm a').format(
                        DateTime.parse(Event['dateTime'])) ==
                        ''
                        ? "Test dateTime"
                        : DateFormat('d MMMM, h:mm a')
                        .format(DateTime.parse(Event['dateTime'])),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 17.5, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/locationIcon.svg',
                    height: 16.33,
                    width: 13.67,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    Event == null
                        ? 'Test Venue'
                        : Event['venue'] ?? "Test Venue",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                RSVPIcons(
                  RSVP: Event == null ? [] : Event['RSVP'] ?? [],
                ),
                Text(
                  '${Event == null ? '0' : Event['starts'] ?? '0'} starts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),

            Divider(
              height: 2,
              color: TextColors.muted,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 4, 16),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: implement See Insights
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: TextColors.primaryDark, elevation: 0),
                    child: Container(
                      height: 30,
                      width: 205,
                      alignment: Alignment.center,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
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

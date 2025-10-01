import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/screens/org_screens/RSVPIcons.dart';
import 'package:frontend/screens/org_screens/active_events_menu.dart';
import 'package:frontend/screens/org_screens/rsvp_info_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ActiveEventsScreen extends StatefulWidget {
  ActiveEventsScreen({super.key});

  @override
  State<ActiveEventsScreen> createState() => _ActiveEventsScreenState();
}

class _ActiveEventsScreenState extends State<ActiveEventsScreen> {
  var Events = null;

  @override
  void initState() {
    INIT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: Events == null ? 2 : Events.length,
      itemBuilder: (context, index) => _ActiveEventTile(
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
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          Events = jsonDecode(response.body);
        });
      }
    }
  }
}

class _ActiveEventTile extends StatelessWidget {
  const _ActiveEventTile({super.key, required this.Event});

  final Event;

  @override
  Widget build(BuildContext context) {
    return _ActiveEventsCard(
      Event: Event,
    );
  }
}

class _ActiveEventsCard extends StatefulWidget {
  const _ActiveEventsCard({super.key, required this.Event});

  final Event;

  @override
  State<_ActiveEventsCard> createState() =>
      _ActiveEventsCardState(Event: Event);
}

class _ActiveEventsCardState extends State<_ActiveEventsCard> {
  _ActiveEventsCardState({required this.Event});

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
                    ? 'https://via.placeholder.com/400x160.png/E4E4E7/000000?text=No+Image'
                    : Event['banner'] ??
                        'https://via.placeholder.com/400x160.png/E4E4E7/000000?text=No+Image',
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
                Event == null ? 'Test Event' : Event['title'] ?? "Test Event",
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
                        ? 'Test DateTime'
                        : DateFormat('d MMMM, h:mm a').format(
                                    DateTime.parse(Event['dateTime'])) ==
                                ''
                            ? "Test DateTime"
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
                  '${Event == null ? '0' : Event['views'] ?? '0'} views',
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
                const SizedBox(height: 72),
                const SizedBox(width: 16),
                SizedBox(
                  width: 161,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: implement See Insights
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF09090B),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
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
                const SizedBox(width: 4),
                SizedBox(
                  width: 87,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: implement Edit
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4E4E7),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mode_edit_outlined,
                          color: Colors.black,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Edit',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4E4E7),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        showActiveEventsMenu(context, Event);
                      },
                      child: const Icon(
                        Icons.more_horiz,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/screens/calendar_screen.dart';
import 'package:frontend/screens/org_screens/event_creation_form_srceen.dart';
import 'package:frontend/screens/org_screens/events_screen.dart';
import 'package:frontend/screens/org_screens/tentative_event_add_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/models/event.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:dotted_border/dotted_border.dart';

class HomeScreenOrg extends StatefulWidget {
  const HomeScreenOrg({super.key});

  @override
  State<HomeScreenOrg> createState() => _HomeScreenOrgState();
}

class _HomeScreenOrgState extends State<HomeScreenOrg> {
  int selectedindex = 0;
  int selectedvalue = 0;
  bool _isExpanded = false;
  List<Event>? events;
  final List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(Remix.calendar_2_line), label: 'Calendar'),
    BottomNavigationBarItem(icon: Icon(Remix.coupon_2_line), label: 'Events'),
    BottomNavigationBarItem(
        icon: Icon(Remix.account_circle_line), label: 'Profile'),
  ];
  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CalendarScreen()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EventsScreen()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    }
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

  Widget _buildTextButton({
    required String label,
    required VoidCallback onPressed,
    required double bottomOffset,
  }) {
    return Positioned(
      right: 0,
      bottom: bottomOffset,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 39, 39, 42),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 4,
          //shadowColor: Colors.grey.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1000),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(8),
        title: Text(
          'Home',
          style: TextStyle(
            color: Color.fromARGB(255, 39, 39, 42),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => {
              //Go to notifications page
            },
            icon: Icon(Remix.notification_3_line),
            padding: EdgeInsets.only(left: 8, right: 8),
            iconSize: 24,
          ),
          IconButton(
            onPressed: () {
              //?
            },
            icon: Icon(Remix.shopping_bag_line),
            padding: EdgeInsets.only(left: 8, right: 8),
            iconSize: 24,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Remix.apps_2_ai_fill),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      iconSize: 24,
                    ),
                    Stack(
                      children: [
                        Text(
                          "Timeline",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color.fromARGB(255, 39, 39, 42),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Container(height: 3, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 4),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedvalue = 1;
                        });
                        //Go to Drafts page
                      },
                      icon: Icon(
                        Remix.draft_line,
                        color: Color.fromARGB(255, 159, 159, 169),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    const Text(
                      'Drafts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color.fromARGB(255, 159, 159, 169),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(height: 1, color: Color.fromARGB(255, 228, 228, 231)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events == null ? 0 : events!.length,
              itemBuilder: (context, index) => EventTile(event: events![index]),
            ),
            if (events == null || events!.isEmpty) ...[
              SizedBox(height: 8),
              DottedBorder(
                color: Color.fromARGB(255, 255, 137, 4),
                strokeWidth: 1,
                dashPattern: [6, 6],
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                borderType: BorderType.RRect,
                radius: Radius.circular(16),
                child: SizedBox(
                  width: 296,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircleAvatar(
                          radius: 1000,
                          backgroundColor: Color.fromARGB(255, 255, 237, 212),
                          child: Icon(
                            Remix.alert_fill,
                            size: 24,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Timeline',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.25,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Plan ahead and keep track of your events here, while\n'
                        'keeping your co-heads and team in sync.',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sharing dates and venues here helps other clubs\nprevent scheduling conflicts.',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 12,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(296, 40),
                          backgroundColor: Color.fromARGB(255, 39, 39, 42),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TentativeEventAddScreen()));
                        },
                        child: const Text(
                          'Add Tentative Events',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 250, 250, 250),
                            fontSize: 14,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(296, 40),
                          backgroundColor: Color.fromARGB(255, 228, 228, 231),
                          foregroundColor: Color.from(
                            alpha: 1,
                            red: 39,
                            green: 39,
                            blue: 42,
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Learn More',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 39, 39, 42),
                            fontSize: 14,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (events != null && events!.length <= 2) ...[
              if (events!.length == 1) ...[SizedBox(height: 145)],
              DottedBorder(
                color: Color.fromARGB(255, 255, 137, 4),
                strokeWidth: 1,
                dashPattern: [6, 6],
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                borderType: BorderType.RRect,
                radius: Radius.circular(16),
                child: SizedBox(
                  width: 296,
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeline',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.25,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Log your event ideas early with tentative dates and\nvenues, and refine the details as plans progress.',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Color.fromARGB(255, 39, 39, 42),
                              backgroundColor: Color.fromARGB(
                                255,
                                228,
                                228,
                                231,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  1000,
                                ),
                              ),
                            ),
                            child: Text(
                              'Learn More',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TentativeEventAddScreen()));
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 39, 39, 42),
                              foregroundColor: Color.fromARGB(
                                255,
                                250,
                                250,
                                250,
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(
                                  1000,
                                ),
                              ),
                            ),
                            child: Text(
                              'Add Tentative Events',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (events != null && events!.length > 2)
          ? SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  if (_isExpanded) ...[
                    _buildTextButton(
                      label: 'New Event',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EventCreationFormScreen()));
                      },
                      bottomOffset: 180,
                    ),
                    _buildTextButton(
                      label: 'Go to Drafts',
                      onPressed: () {
                        //Go to Drafts Page
                      },
                      bottomOffset: 120,
                    ),
                    _buildTextButton(
                      label: 'Timeline (Tentative) Event',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TentativeEventAddScreen()));
                      },
                      bottomOffset: 60,
                    ),
                  ],
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      backgroundColor: Color.fromARGB(255, 39, 39, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Icon(
                        _isExpanded ? Remix.close_large_line : Remix.add_line,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: _items,
        currentIndex: selectedindex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class EventTile extends StatelessWidget {
  final Event event;
  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.dateTime.isAfter(DateTime.now())) {
      return Container(
        //width: double.infinity,
        width: 328,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMMM').format(event.dateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color.fromARGB(255, 39, 39, 42),
                  ),
                ),
                Icon(Remix.arrow_up_s_line, size: 16),
              ],
            ),
            SizedBox(height: 4),
            ClipRect(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 228, 228, 231),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(8),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(width: 4, color: Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event.banner != null &&
                                  event.banner!.isNotEmpty) ...[
                                Container(
                                  padding: EdgeInsets.all(4),
                                  color: Color.fromARGB(255, 255, 237, 212),
                                  child: Text(
                                    event.banner ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  letterSpacing: 0,
                                  color: Color.fromARGB(255, 39, 39, 42),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Remix.time_line, size: 14),
                                  SizedBox(width: 2),
                                  Text(
                                    DateFormat('h:mm a').format(event.dateTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0,
                                      color: Color.fromARGB(255, 39, 39, 42),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Remix.map_pin_line, size: 14),
                                  SizedBox(width: 2),
                                  Text(
                                    event.venue ?? "Online",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0,
                                      color: Color.fromARGB(255, 39, 39, 42),
                                    ),
                                  ),
                                ],
                              ),
                              if (event.getTagTitles().isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: event
                                      .getTagTitles()
                                      .map<Widget>(
                                        (tagTitle) => Chip(
                                          label: Text(tagTitle),
                                          labelStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(
                                              255,
                                              39,
                                              39,
                                              42,
                                            ),
                                            fontSize: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                              1000,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

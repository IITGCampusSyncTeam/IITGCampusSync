import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/event.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/calendar_widgets.dart';
import 'package:http/http.dart' as http;

class OrganizerCalendarScreen extends StatefulWidget {
  final String organizerID;
  const OrganizerCalendarScreen({super.key, this.organizerID = ""});

  @override
  State<OrganizerCalendarScreen> createState() =>
      _OrganizerCalendarScreenState();
}

enum ViewType { timeline, weekly, monthly }

ViewType _currentView = ViewType.timeline;

class _OrganizerCalendarScreenState extends State<OrganizerCalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<Event> allEvents = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(3000, 12, 31),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> fetchEvents() async {
    try {
      final token = await getAccessToken(); // Retrieve authentication token
      if (token == 'error') {
        setState(() {
          isLoading = false;
          errorMessage = 'Authentication required.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${backend.uri}/get-events'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> eventList = jsonDecode(response.body);
        List<Map<String, dynamic>> events = eventList.map((item) {
          return item as Map<String, dynamic>;
        }).toList();
        events.forEach((e) {
          try {
            allEvents.add(Event.fromJson(e));
          } catch (er) {
            print(er);
          }
        });
        isLoading = false;
        print(events.length);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load events.';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    print(organizerEvents.length);
    // fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.search, color: Colors.grey),
                          ),
                          Text(
                            'Search Events',
                          ),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.view_agenda),
                    color: _currentView == ViewType.timeline
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.timeline;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.view_week),
                    color: _currentView == ViewType.weekly
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.weekly;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month),
                    color: _currentView == ViewType.monthly
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.monthly;
                      });
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : _buildCurrentView(),
            ),
          ],
        ),
        
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case ViewType.timeline:
        return buildTimelineView(organizerEvents, widget.organizerID);
      case ViewType.weekly:
        return buildWeeklyView(
            organizerEvents, selectedDate, widget.organizerID, (newDate) {
          setState(() {
            selectedDate = newDate;
          });
        });
      case ViewType.monthly:
        return buildCalendarView(organizerEvents, selectedDate, (newDate) {
          setState(() {
            selectedDate = newDate;
          });
        });
    }
  }
}

List<Event> organizerEvents = [
  Event(
    club: "Coding Club",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 31, 19, 30, 0),
    description: "description1",
    title: "Event1",
    feedbacks: [],
    notifications: [],
    participants: [],
  ),
  Event(
    club: "FEC",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 31, 9, 40, 0),
    description: "description2",
    title: "Event2",
    feedbacks: [],
    notifications: [],
    participants: [],
  ),
  Event(
    club: "Robotics",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 4, 1, 19, 30, 0),
    description: "description3",
    title: "Event3",
    feedbacks: [],
    notifications: [],
    participants: [],
  )
];

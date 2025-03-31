import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/apis/protected.dart';
import 'package:frontend/constants/endpoints.dart';
import 'package:frontend/models/event.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/calendar_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../models/calendar_event.dart';

class CalendarScreen extends StatefulWidget {
  final String userID;
  const CalendarScreen({super.key, this.userID = ""});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

enum ViewType { timeline, grid, calendar }

ViewType _currentView = ViewType.timeline;

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  List<CalendarEvent> filteredEvents = [];
  List<Event> allEvents = [];
  List<Event> myEvents = [];
  bool isLoading = false;
  String errorMessage = '';
  bool _showMyEventsOnly = false;

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
        // filteredEvents = events
        //     .where((e) =>
        //         e.startTime.day == selectedDate.day &&
        //         e.startTime.month == selectedDate.month &&
        //         e.startTime.year == selectedDate.year)
        //     .toList();
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
    print(events.length);
    // fetchEvents();
    // filteredEvents = events
    //     .where((e) =>
    //         e.startTime.day == selectedDate.day &&
    //         e.startTime.month == selectedDate.month &&
    //         e.startTime.year == selectedDate.year)
    //     .toList();
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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('All events', !_showMyEventsOnly),
                    _buildToggleButton('My events', _showMyEventsOnly),
                  ],
                ),
              ),
            ),

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
                    icon: Icon(Icons.grid_view),
                    color: _currentView == ViewType.grid
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.grid;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    color: _currentView == ViewType.calendar
                        ? Colors.blue
                        : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.calendar;
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

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMyEventsOnly = text == 'My events' ? true : false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    List<Event> filteredEvents = _showMyEventsOnly
        ? myEventsDummy
        // ? events
        //     .where((event) => event.participants.contains(widget.userID))
        //     .toList()
        : events;

    switch (_currentView) {
      case ViewType.timeline:
        return buildTimelineView(filteredEvents, widget.userID);
      case ViewType.grid:
        return buildGridView(filteredEvents, widget.userID);
      case ViewType.calendar:
        return buildCalendarView(filteredEvents,selectedDate,(newDate) {
      setState(() {
        selectedDate = newDate;
      });
    });
    }
  }

  Widget _buildCalendarDays() {
    final days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map((day) => Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

List<Event> events = [
  Event(
    club: "Coding Club",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 23, 19, 30, 0),
    description: "description1",
    title: "Event1",
    feedbacks: [],
    notifications: [],
    participants: [],
  ),
  Event(
    club: "FEC",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 23, 9, 40, 0),
    description: "description2",
    title: "Event2",
    feedbacks: [],
    notifications: [],
    participants: [],
  ),
  Event(
    club: "Robotics",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 25, 19, 30, 0),
    description: "description3",
    title: "Event3",
    feedbacks: [],
    notifications: [],
    participants: [],
  )
];
List<Event> myEventsDummy = [
  Event(
    club: "FEC",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 23, 9, 40, 0),
    description: "description2",
    title: "Event2",
    feedbacks: [],
    notifications: [],
    participants: [],
  ),
  Event(
    club: "Robotics",
    createdBy: "alkdj",
    dateTime: DateTime(2025, 3, 25, 19, 30, 0),
    description: "description3",
    title: "Event3",
    feedbacks: [],
    notifications: [],
    participants: [],
  )
];

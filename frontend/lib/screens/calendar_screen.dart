import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/event.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/calendar_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/eventProvider.dart';

import 'package:frontend/constants/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

enum ViewType { timeline, grid, calendar }

class _CalendarScreenState extends State<CalendarScreen> {
  ViewType _currentView = ViewType.timeline;
  bool _showMyEventsOnly = false;
  String? _userId; // Will be loaded from SharedPreferences
  @override
  void initState() {
    super.initState();
    _loadUserId();

    // Initialize the provider by fetching events when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.fetchAllEvents();
    });
  }

  void _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString('user_data');
    print('🔍 user_data from SharedPreferences: $userDataJson');
    if (userDataJson != null) {
      final userMap = jsonDecode(userDataJson);
      setState(() {
        _userId = userMap['_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the EventProvider
    print("🧱 Building CalendarScreen | userId: $_userId");
    final eventProvider = Provider.of<EventProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: PageColors.background,
        body: Column(
          children: [
            // Toggle buttons for All events and My events
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: PageColors.foreground,
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

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      height: 44,
                      decoration: BoxDecoration(
                        color: PageColors.foreground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Icon(Icons.search, color: TextColors.muted,),
                          ),
                          Text('Search Events ...', style: TextStyle(fontFamily: 'Sans', fontSize: 14, letterSpacing: -0.5, color: TextColors.muted),),
                        ],
                      ),
                    ),
                  )),
                  SizedBox(width: 4),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PageColors.foreground,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: PageColors.icon,),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // View selector buttons
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

            // Main content with loading state from provider
            Expanded(
              child: eventProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : eventProvider.errorMessage.isNotEmpty
                      ? Center(child: Text(eventProvider.errorMessage))
                      : _buildCurrentView(eventProvider),
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
          _showMyEventsOnly = text == 'My events';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? OnSurfaceColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : TextColors.primaryDark,
            // fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(EventProvider provider) {
    if (_userId == null) {
      return const Center(
        child: CircularProgressIndicator() // Wait for userID
      );
    }

    List<Event> filteredEvents = _showMyEventsOnly
        ? provider.allEvents
            .where((event) => event.participants.contains(_userId))
            .toList()
        : provider.allEvents;

    switch (_currentView) {
      case ViewType.timeline:
        return buildTimelineView(filteredEvents, _userId!);
      case ViewType.grid:
        return buildGridView(filteredEvents, _userId!);
      case ViewType.calendar:
        return buildCalendarView(
          context,
          filteredEvents,
          provider.selectedDate,
          (newDate) => provider.setSelectedDate(newDate),
          _userId!
        );
    }
  }
}

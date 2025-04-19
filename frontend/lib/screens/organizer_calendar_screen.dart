import 'package:flutter/material.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/widgets/calendar_widgets.dart';
import 'package:provider/provider.dart';

import '../providers/eventProvider.dart'; // Import the provider

class OrganizerCalendarScreen extends StatefulWidget {
  final String organizerID;
  const OrganizerCalendarScreen({super.key, this.organizerID = ""});

  @override
  State<OrganizerCalendarScreen> createState() => _OrganizerCalendarScreenState();
}

enum ViewType { timeline, weekly, monthly }

class _OrganizerCalendarScreenState extends State<OrganizerCalendarScreen> {
  ViewType _currentView = ViewType.timeline;

  @override
  void initState() {
    super.initState();
    // Initialize the provider by fetching events when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the EventProvider
    final eventProvider = Provider.of<EventProvider>(context);
    
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
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
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.search, color: Colors.grey),
                            ),
                            Text('Search Events'),
                          ],
                        ),
                      ),
                    )
                  ),
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

            // View selector buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.view_agenda),
                    color: _currentView == ViewType.timeline ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.timeline;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.view_week),
                    color: _currentView == ViewType.weekly ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.weekly;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month),
                    color: _currentView == ViewType.monthly ? Colors.blue : Colors.grey,
                    onPressed: () {
                      setState(() {
                        _currentView = ViewType.monthly;
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
        // Add floating action button for creating new events
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to create event screen or show dialog
          },
          child: Icon(Icons.add),
          tooltip: 'Create Event',
        ),
      ),
    );
  }

  // Modified to use the provider
  Widget _buildCurrentView(EventProvider provider) {
    switch (_currentView) {
      case ViewType.timeline:
        return buildTimelineView(
          provider.allEvents, 
          widget.organizerID
        );
      case ViewType.weekly:
        return buildWeeklyView(
          provider.getEventsForWeek(provider.selectedDate),
          provider.selectedDate,
          widget.organizerID,
          (newDate) => provider.setSelectedDate(newDate)
        );
      case ViewType.monthly:
        return buildCalendarView(
          provider.getEventsForMonth(
            provider.selectedDate.year, 
            provider.selectedDate.month
          ),
          provider.selectedDate,
          (newDate) => provider.setSelectedDate(newDate)
        );
    }
  }
}

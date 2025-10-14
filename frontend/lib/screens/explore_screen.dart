import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/apis/events/event_api.dart';
import 'package:frontend/models/event.dart'; // Import the Event model
import 'package:frontend/screens/payment_screen.dart';
import 'package:frontend/screens/sharing.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/eventProvider.dart';
import '../services/notification_services.dart';
import '../widgets/event_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Event> events = []; // Now using the Event model
  bool isLoading = true;
  EventAPI eventAPI = EventAPI();
  NotificationServices notificationServices = NotificationServices();
  final Set<String> _selectedFilters = {'Upcoming'};
  int _selectedIndex = 0; // Track the selected navigation item

  // Pagination controls
  int _eventsPerPage = 3; // Number of events to display per page
  int _currentPage = 0; // Current page index (0-based)

  // Setup notification details
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          'daily_channel_id', 'Daily Notifications',
          channelDescription: 'Daily Notification Channel',
          importance: Importance.max,
          priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchUpcomingEvents();
    });

    // Initialize notification services
    notificationServices.requestNotificationPermission;
    notificationServices.forgroundMessage();
    notificationServices.setupInteractMessage(context);
    notificationServices.getDeviceToken().then((value) {
      print('device token');
      print(value);
    });
  }

  void loadEvents() async {
    try {
      setState(() {
        isLoading = true;
      });

      final eventList = await eventAPI.fetchEvents();
      setState(() {
        // Parse the events using the Event model
        events =
            eventList.map((eventData) => Event.fromJson(eventData)).toList();
        // Sort events by date (newest first)
        events.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        // Reset pagination when loading new events
        _currentPage = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onFilterTap(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            return RefreshIndicator(
              onRefresh: () => eventProvider.fetchAllData(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 5),
                        _buildSearchBar(),
                        const SizedBox(height: 4),
                        _buildOrganisersSection(),
                      ],
                    ),
                  ),

                  // Event List Section
                  if(events.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        final firstEvent = events[0];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventShareScreen(
                              eventTitle: firstEvent.title,
                              eventDescription: firstEvent.description,
                              eventDateTime: firstEvent.dateTime.toString(),
                              eventLocation: firstEvent.venue ?? "Unknown venue",
                              eventLink: "https://example.com/event/${firstEvent.id}",
                              imageUrl: firstEvent.banner ?? "https://via.placeholder.com/300",
                            ),
                          ),
                        );
                      },
                      child: Text('Share'),
                    ),
                  if (eventProvider.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (eventProvider.upcomingEvents.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text("No events found.")),
                    )
                  else
                    SliverList.builder(
                      itemCount: eventProvider.upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = eventProvider.upcomingEvents[index];
                        return EventCard(
                          event: event,
                          style: CardStyle.full,
                          onRsvpPressed: () => eventProvider.toggleRsvpStatus(event.id),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }




  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Hey Shivangi!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Sans TRIAL'),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.local_mall_outlined),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PaymentScreen()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Show notification permission or settings or show a new screen where notifs will be stored
                  notificationServices.requestNotificationPermission;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search events...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_outlined),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
  //
  // Widget _buildFilterChips() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //
  //       SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: Row(
  //           children: [
  //             _buildFilterChip("Upcoming", false),
  //             const SizedBox(width: 8),
  //             _buildFilterChip("Following", false),
  //             const SizedBox(width: 8),
  //             _buildFilterChip("My interests", false),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildFilterChip(String label, bool isSelected) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: isSelected ? Colors.black : Colors.grey[200],
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       label,
  //       style: TextStyle(
  //         color: isSelected ? Colors.white : Colors.black,
  //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEventsList(List<Event> events,EventProvider eventProvider) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No events found')),
      );
    }

    // Calculate pagination values
    int totalEvents = events.length;
    int totalPages = (totalEvents / _eventsPerPage).ceil();
    int startIndex = _currentPage * _eventsPerPage;
    int endIndex = (startIndex + _eventsPerPage) > totalEvents
        ? totalEvents
        : startIndex + _eventsPerPage;

    // Get current page events
    List<Event> currentEvents = events.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Events for current page
        ...currentEvents.map((event) {
          return EventCard(
            style: CardStyle.full,
            onRsvpPressed: () {
              Provider.of<EventProvider>(context, listen: false)
                  .toggleRsvpStatus(event.id);
            }, event: event,
          );
        }).toList(),

        // Pagination controls
        // _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous button
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
              setState(() {
                _currentPage--;
              });
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Previous'),
          ),

          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Page ${_currentPage + 1} of $totalPages',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Next button
          ElevatedButton(
            onPressed: _currentPage < totalPages - 1
                ? () {
              setState(() {
                _currentPage++;
              });
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  List<String> _generateTags(Event event) {
    if (event.tag.isNotEmpty) {
      return event.getTagTitles();
    }

    List<String> tags = [];
    if (event.club?.name != null) tags.add(event.club!.name);

    // If no tags are available, add at least one default tag
    if (tags.isEmpty) tags.add('Campus Event');

    return tags;
  }

  Widget _buildOrganisersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            "Organisers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 90,
          child: Row(
            children: [
              SizedBox(width: 16),
              OrganiserItem(name: "Whitespace", color: Colors.red),
              OrganiserItem(name: "CnA", color: Colors.purple),
              OrganiserItem(name: "Cadence", color: Colors.indigo),
              OrganiserItem(name: "Litcafe", color: Colors.orange),
              SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }
//
// Widget _buildBottomNavigationBar() {
//   return BottomNavigationBar(
//     items: const [
//       BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
//       BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_today), label: "Calendar"),
//       BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//     ],
//     currentIndex: _selectedIndex,
//     selectedItemColor: Colors.black,
//     unselectedItemColor: Colors.grey,
//     onTap: (index) {
//       setState(() {
//         _selectedIndex = index; // Update the selected index
//       });
//
//       if (index == 1) {
//         print("Navigating to Calendar screen");
//         // Navigate to Calendar screen - replacing with print for debugging
//         try {
//           Navigator.of(context).pushNamed('/calendar');
//         } catch (e) {
//           print("Navigation error: $e");
//           // Fallback direct navigation if named route is not defined
//           // Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarScreen()));
//         }
//       } else if (index == 2) {
//         print("Navigating to Profile screen");
//         // Navigate to Profile screen - replacing with print for debugging
//         try {
//           Navigator.of(context).pushNamed('/profile');
//         } catch (e) {
//           print("Navigation error: $e");
//           // Fallback direct navigation if named route is not defined
//           // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
//         }
//       }
//     },
//   );
// }
}

class OrganiserItem extends StatelessWidget {
  final String name;
  final Color color;

  const OrganiserItem({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Text(
              name[0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

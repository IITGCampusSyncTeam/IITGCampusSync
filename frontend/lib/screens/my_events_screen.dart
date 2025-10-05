import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/eventProvider.dart';
import '../widgets/event_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.fetchRsvpdUpcomingEvents();
      provider.fetchAttendedEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text("My Events", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number),
                  SizedBox(width: 8),
                  Text("Upcoming"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text("Attended"),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(eventProvider.rsvpdUpcomingEvents, eventProvider),
              _buildEventList(eventProvider.attendedEvents, eventProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Event> events, EventProvider provider) {
    if (events.isEmpty) {
      return const Center(child: Text("No events in this category."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          style: CardStyle.compact, // Use the compact style for this screen
          onRsvpPressed: () {
            if (event.dateTime.isAfter(DateTime.now())) {
              provider.toggleRsvpStatus(event.id);
            }
          },
          banner: event.title.toUpperCase(),
          title: event.title,
          organizer: event.club?.name ?? 'Unknown Organizer',
          dateTime: event.dateTime.toString(), // Format this as needed
          location:
          "TBD", // You might need to add location to your Event model
          tags: event.getTagTitles(),
          imageUrl:
          "https://images.unsplash.com/photo-1581322339219-8d8282b70610", // Default image
          description: event.description,
        );
      },
    );
  }
}
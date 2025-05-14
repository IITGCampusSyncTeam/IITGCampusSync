import 'package:flutter/material.dart';
import 'package:frontend/screens/org_screens/event_creation_form_srceen.dart';

class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool showMyEvents = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Toggle Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => showMyEvents = false),
                    child: _toggleButton('All Events', !showMyEvents),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => showMyEvents = true),
                    child: _toggleButton('My Events', showMyEvents),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  _circleIcon(Icons.tune),
                  SizedBox(width: 10),
                  _circleIcon(Icons.calendar_today),
                ],
              ),
              SizedBox(height: 16),

              // Show All or My Events using same layout
              Expanded(
                child: OrgEventScreen(
                  isMyEvents: showMyEvents,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _circleIcon(IconData icon) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: Icon(icon, color: Colors.black),
    );
  }
}

class OrgEventScreen extends StatelessWidget {
  final bool isMyEvents;

  OrgEventScreen({this.isMyEvents = false});

  final List<Map<String, dynamic>> allEvents = [
    {
      'date': '17 April',
      'title': 'Figma Workshop hehe',
      'club': 'Coding Club',
      'image': 'https://i.imgur.com/5Qf4WcN.png',
      'datetime': '16 April, 7:00 PM',
      'venue': 'Lecture Hall',
      'tags': ['Design', 'Figma', 'DesforDev'],
      'isMine': false,
    },
    {
      'date': '18 April',
      'title': 'Flutter Bootcamp',
      'club': 'Mobile Club',
      'image': 'https://i.imgur.com/YZ4XJL5.png',
      'datetime': '18 April, 5:00 PM',
      'venue': 'Room 101',
      'tags': ['Flutter', 'Mobile Dev'],
      'isMine': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final events = isMyEvents
        ? allEvents.where((e) => e['isMine'] == true).toList()
        : allEvents;

    Map<String, List<Map<String, dynamic>>> groupedEvents = {};
    for (var event in events) {
      groupedEvents.putIfAbsent(event['date'], () => []).add(event);
    }

    return events.isEmpty
        ? Center(
            child:
                Text("No events found", style: TextStyle(color: Colors.white)))
        : ListView(
            children: groupedEvents.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  ...entry.value
                      .map((event) => _eventCard(context, event))
                      .toList(),
                  SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
  }

  Widget _eventCard(BuildContext context, Map<String, dynamic> event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  event['image'],
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              if (event['isMine'])
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white70,
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventCreationFormScreen()),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'],
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(event['club'], style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16),
                    SizedBox(width: 4),
                    Text(event['datetime']),
                    SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 4),
                    Text(event['venue']),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: event['tags']
                      .map<Widget>((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          ))
                      .toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

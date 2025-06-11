import 'package:flutter/material.dart';

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

              // Body Screen Switch
              Expanded(
                child: showMyEvents ? MyEventScreen() : OrgEventScreen(),
              )
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
  final List<Map<String, dynamic>> events = [
    {
      'date': '17 April',
      'title': 'Figma Workshop hehe',
      'club': 'Coding Club',
      'image': 'https://i.imgur.com/5Qf4WcN.png',
      'datetime': '16 April, 7:00 PM',
      'venue': 'Lecture Hall',
      'tags': ['Design', 'Figma', 'DesforDev'],
    },
    {
      'date': '18 April',
      'title': 'Flutter Bootcamp',
      'club': 'Mobile Club',
      'image': 'https://i.imgur.com/YZ4XJL5.png',
      'datetime': '18 April, 5:00 PM',
      'venue': 'Room 101',
      'tags': ['Flutter', 'Mobile Dev'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedEvents = {};
    for (var event in events) {
      groupedEvents.putIfAbsent(event['date'], () => []).add(event);
    }

    return ListView(
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
            ...entry.value.map((event) => _eventCard(context, event)).toList(),
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
          // Banner
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
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  child: Icon(Icons.edit, color: Colors.black),
                ),
              )
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

class MyEventScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://i.imgur.com/5Qf4WcN.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text(
                      'Tech Conference 2024',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📍 Venue: Auditorium'),
                    Text('📅 Date: 15 March 2024'),
                    Text('⏰ Time: 10:00 AM - 2:00 PM'),
                    Text('🎯 Organized by: XYZ Club'),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text('Tech')),
                        Chip(label: Text('Conference')),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.check),
                          label: Text('Registered'),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple),
                        ),
                        OutlinedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          onPressed: () {},
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

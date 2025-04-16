import 'package:flutter/material.dart';

class MyEventsScreen extends StatefulWidget {
  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final List<Event> _events = [
    Event(name: 'Tech Talk', date: '15 March 2024', venue: 'Auditorium', tag: 'Tech'),
    Event(name: 'Drama Night', date: '16 March 2024', venue: 'Hall A', tag: 'Cultural'),
    Event(name: 'Coding Marathon', date: '17 March 2024', venue: 'Hall B', tag: 'Tech'),
    Event(name: 'Dance Battle', date: '18 March 2024', venue: 'Auditorium', tag: 'Cultural'),
    Event(name: 'Football Finals', date: '19 March 2024', venue: 'Ground', tag: 'Sports'),
  ];

  String _searchQuery = '';
  String _selectedTag = 'All';

  @override
  Widget build(BuildContext context) {
    List<Event> filteredEvents = _events.where((event) {
      final matchesSearch = event.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == 'All' || event.tag == _selectedTag;
      return matchesSearch && matchesTag;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('My Events')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Events',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 12),

            // Filter dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Filter by Tag',
                border: OutlineInputBorder(),
              ),
              value: _selectedTag,
              items: ['All', 'Tech', 'Cultural', 'Sports']
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTag = value!;
                });
              },
            ),
            SizedBox(height: 16),

            // Event list
            Expanded(
              child: filteredEvents.isEmpty
                  ? Center(child: Text('No events match your filters'))
                  : ListView.builder(
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 16.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(event.name),
                            subtitle: Text('Date: ${event.date}\nVenue: ${event.venue}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to event details
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

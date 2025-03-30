import 'package:flutter/material.dart';

class PastEventScreen extends StatelessWidget {
  final List<Map<String, String>> pastEvents = [
    {'name': 'Tech Conference 2023', 'date': '12 March 2023', 'venue': 'Auditorium'},
    {'name': 'Cultural Fest', 'date': '25 April 2023', 'venue': 'Hall A'},
    {'name': 'Sports Meet', 'date': '10 June 2023', 'venue': 'Stadium'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Past Events')),
      body: pastEvents.isEmpty
          ? Center(child: Text('No past events available'))
          : ListView.builder(
        itemCount: pastEvents.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(pastEvents[index]['name']!),
              subtitle: Text('${pastEvents[index]['date']} | ${pastEvents[index]['venue']}'),
              leading: Icon(Icons.event_available),
            ),
          );
        },
      ),
    );
  }
}

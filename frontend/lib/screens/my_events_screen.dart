import 'package:flutter/material.dart';

void main() {
  runApp(EventApp());
}

class EventApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyEventsScreen(),
    );
  }
}

// My Events Screen
class MyEventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Events')),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: 5, // Replace with dynamic event count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(16.0),
              title: Text('Event ${index + 1}'),
              subtitle: Text('Date: 15 March 2024\nVenue: Auditorium'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to event details
              },
            ),
          );
        },
      ),
    );
  }
}

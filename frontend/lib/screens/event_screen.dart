import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List events = [];
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateTimeController = TextEditingController();
  final clubController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = 'http://192.168.0.102:3000/get-events';
    try {
      final response = await http.get(Uri.parse(url));
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
        });
      } else {
        _showErrorDialog('Failed to load events');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  Future<void> createEvent() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final dateTime = dateTimeController.text;
    final club = clubController.text;

    if (title.isEmpty ||
        description.isEmpty ||
        dateTime.isEmpty ||
        club.isEmpty) {
      _showErrorDialog('Please fill in all the fields');
      return;
    }

    final url = 'http://192.168.0.102:3000/create-event';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'description': description,
          'dateTime': dateTime,
          'club': club,
          'createdBy':
              '5f50b61f78d1e74d8c3f0002', // Replace with actual user ID
          'participants': [],
          'feedbacks': [],
          'notifications': []
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog('Event created successfully');
        fetchEvents(); // Refresh event list
        _clearInputFields(); // Clear fields after submission
      } else {
        _showErrorDialog('Error creating event');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    }
  }

  void _clearInputFields() {
    titleController.clear();
    descriptionController.clear();
    dateTimeController.clear();
    clubController.clear();
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Campus Sync')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Event creation form
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: dateTimeController,
              decoration: InputDecoration(
                  labelText: 'Date and Time (YYYY-MM-DD HH:MM)'),
            ),
            TextField(
              controller: clubController,
              decoration: InputDecoration(labelText: 'Club ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: createEvent,
              child: Text('Create Event'),
            ),
            SizedBox(height: 24),
            // Event List
            Expanded(
              child: events.isNotEmpty
                  ? ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          child: ListTile(
                            title: Text(event['title']),
                            subtitle: Text(event['description']),
                            trailing: Text(event['dateTime']),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No events found')),
            ),
          ],
        ),
      ),
    );
  }
}

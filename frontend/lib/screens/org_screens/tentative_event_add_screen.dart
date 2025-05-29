import 'package:flutter/material.dart';

import '../../apis/events/event_api.dart';

class TentativeEventAddScreen extends StatefulWidget {
  @override
  _TentativeEventAddScreenState createState() =>
      _TentativeEventAddScreenState();
}

class _TentativeEventAddScreenState extends State<TentativeEventAddScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVenue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Tentative Event')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(_selectedDate == null
                  ? 'Pick Event Date'
                  : 'Event Date: ${_selectedDate.toString().split(' ')[0]}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Venue',
                border: OutlineInputBorder(),
              ),
              items: ['Auditorium', 'Hall A', 'Hall B'].map((String venue) {
                return DropdownMenuItem<String>(
                  value: venue,
                  child: Text(venue),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVenue = value;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final eventName = _eventNameController.text;
                if (eventName.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedVenue != null) {
                  try {
                    await EventAPI().createTentativeEvent(
                      eventName,
                      _selectedDate!,
                      _selectedVenue!,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tentative event created!')),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating event: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

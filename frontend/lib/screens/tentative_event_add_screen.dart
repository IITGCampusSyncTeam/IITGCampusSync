import 'package:flutter/material.dart';

class TentativeEventAddScreen extends StatefulWidget {
  @override
  _TentativeEventAddScreenState createState() =>
      _TentativeEventAddScreenState();
}

class _TentativeEventAddScreenState extends State<TentativeEventAddScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
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
                  : 'Event Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
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
            ListTile(
              title: Text(_selectedTime == null
                  ? 'Pick Event Time'
                  : 'Event Time: ${_selectedTime!.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _selectedTime = pickedTime;
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
              onPressed: () {
                if (_eventNameController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null &&
                    _selectedVenue != null) {
                  Navigator.pop(context);
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

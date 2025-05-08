import 'package:flutter/material.dart';


class TentativeEventAddScreen extends StatefulWidget {
  @override
  _TentativeEventAddScreenState createState() => _TentativeEventAddScreenState();
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
              onPressed: () {
                if (_eventNameController.text.isNotEmpty && _selectedDate != null && _selectedVenue != null) {
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

import 'package:flutter/material.dart';

class EventCreationFormScreen extends StatefulWidget {
  @override
  _EventCreationFormScreenState createState() => _EventCreationFormScreenState();
}

class _EventCreationFormScreenState extends State<EventCreationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedVenue;
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Creation Form')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event description';
                  }
                  return null;
                },
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Tag',
                  border: OutlineInputBorder(),
                ),
                items: ['Tech', 'Cultural', 'Sports'].map((String tag) {
                  return DropdownMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedDate != null && _selectedVenue != null && _selectedTag != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Event Published Successfully!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}